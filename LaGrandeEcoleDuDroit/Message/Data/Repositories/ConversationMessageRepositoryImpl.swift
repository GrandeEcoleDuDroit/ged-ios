import Combine

class ConversationMessageRepositoryImpl: ConversationMessageRepository {
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    private let conversationsMessagePublisher = CurrentValueSubject<[String: ConversationMessage], Never>([:])
    var conversationsMessage: AnyPublisher<[String: ConversationMessage], Never> {
        conversationsMessagePublisher.eraseToAnyPublisher()
    }
    private var cancellables: Set<AnyCancellable> = []
    private var messageCancellable: AnyCancellable?

    init(
        conversationRepository: ConversationRepository,
        messageRepository: MessageRepository
    ) {
        self.conversationRepository = conversationRepository
        self.messageRepository = messageRepository
        listen()
    }
    
    private func listen() {
        conversationsPublisher()
            .sink { [weak self] conversations in
                self?.messageCancellable?.cancel()
                self?.messageCancellable = self?.messagePublisher(from: conversations)
                    .sink { [weak self] conversationMessage in
                        guard let conversationMessage = conversationMessage else {
                            self?.conversationsMessagePublisher.value.removeAll()
                            return
                        }

                        self?.conversationsMessagePublisher.value[conversationMessage.conversation.id] = conversationMessage
                    }
                
            }.store(in: &cancellables)
    }
    
    private func conversationsPublisher() -> AnyPublisher<[Conversation], Never> {
        let initial = getCurrentConversations()
        let updates = conversationRepository.conversationChanges.map { change in
            (change.inserted + change.updated).filter { conversation in
                change.deleted.contains(where: { $0.id == conversation.id }) == false
            }
        }
        
        return Publishers.Merge(initial, updates)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    private func getCurrentConversations() -> Future<[Conversation], Never> {
        Future<[Conversation], Never> { promise in
            Task {
                let conversations = await self.conversationRepository.getConversations()
                promise(.success(conversations))
            }
        }
    }
    
    private func messagePublisher(from conversations: [Conversation]) -> AnyPublisher<ConversationMessage?, Never> {
        guard !conversations.isEmpty else {
            return Just(nil).eraseToAnyPublisher()
        }

        let publishers = conversations.map { conversation in
            let initial = getCurrentLastMessage(conversation: conversation)
            let updates = listenLastMessageChanges(conversation: conversation)
            return initial
                .compactMap { $0 }
                .append(updates)
                .eraseToAnyPublisher()
        }

        return Publishers.MergeMany(publishers)
            .map { Optional($0) }
            .eraseToAnyPublisher()
    }
    
    private func getCurrentLastMessage(conversation: Conversation) -> Future<ConversationMessage?, Never> {
        Future<ConversationMessage?, Never> { promise in
            Task {
                let message = await self.messageRepository.getLastMessage(conversationId: conversation.id)
                if let message = message {
                    promise(.success(ConversationMessage(conversation: conversation, lastMessage: message)))
                } else {
                    promise(.success(nil))
                }
            }
        }
    }
    
    private func listenLastMessageChanges(conversation: Conversation) -> AnyPublisher<ConversationMessage, Never> {
        messageRepository.messageChanges
            .compactMap { change in
                let relevantMessages = (change.inserted + change.updated)
                    .filter { $0.conversationId == conversation.id }

                let nonDeletedMessages = relevantMessages.filter { message in
                    !change.deleted.contains(where: { $0.id == message.id })
                }
                
                let sortedMessages = nonDeletedMessages.sorted { $0.date > $1.date }

                return sortedMessages.first
            }
            .map { message in
                ConversationMessage(conversation: conversation, lastMessage: message)
            }
            .eraseToAnyPublisher()
    }

    
    deinit {
        messageCancellable?.cancel()
        cancellables.forEach { $0.cancel() }
    }
}
