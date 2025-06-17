import Combine

class ConversationMessageRepositoryImpl: ConversationMessageRepository {
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    private var conversationCancellables: Set<AnyCancellable> = []
    private var messageCancellables: [String: AnyCancellable] = [:]
    private let conversationsMessagePublisher = CurrentValueSubject<[String: ConversationMessage], Never>([:])
    var conversationsMessage: AnyPublisher<[String: ConversationMessage], Never> {
        conversationsMessagePublisher.eraseToAnyPublisher()
    }

    init(
        conversationRepository: ConversationRepository,
        messageRepository: MessageRepository
    ) {
        self.conversationRepository = conversationRepository
        self.messageRepository = messageRepository
        listen()
    }
    
    private func listen() {
        listenConversations()
            .sink { [weak self] conversations in
                for conversation in conversations {
                    self?.messageCancellables[conversation.id]?.cancel()
                    
                    let cancellable = self?.listenLastMessage(for: conversation)
                    
                    self?.messageCancellables[conversation.id] = cancellable
                }
            }.store(in: &conversationCancellables)
    }
    
    func clear() {
        messageCancellables.forEach { $0.value.cancel() }
        messageCancellables.removeAll()
        conversationsMessagePublisher.value.removeAll()
    }
    
    private func listenConversations() -> AnyPublisher<[Conversation], Never> {
        let initial = getCurrentConversations()
        let updates = conversationRepository.conversationChanges.map { change in
            change.inserted + change.updated
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
    
    private func listenLastMessage(for conversation: Conversation) -> AnyCancellable {
        listenLastMessage(from: conversation)
            .sink { [weak self] message in
                self?.conversationsMessagePublisher.value[conversation.id] =
                    ConversationMessage(conversation: conversation, lastMessage: message)
            }
    }
    
    private func listenLastMessage(from conversation: Conversation) -> AnyPublisher<Message, Never> {
        let initial = getCurrentLastMessage(conversation: conversation)
            .compactMap { $0 }
            .eraseToAnyPublisher()
        
        let updates = listenLastMessageChanges(conversation: conversation)
        
        return initial
            .append(updates)
            .eraseToAnyPublisher()
    }
    
    private func getCurrentLastMessage(conversation: Conversation) -> Future<Message?, Never> {
        Future<Message?, Never> { promise in
            Task {
                let message = await self.messageRepository.getLastMessage(conversationId: conversation.id)
                promise(.success(message))
            }
        }
    }
    
    private func listenLastMessageChanges(conversation: Conversation) -> AnyPublisher<Message, Never> {
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
            .eraseToAnyPublisher()
    }
}
