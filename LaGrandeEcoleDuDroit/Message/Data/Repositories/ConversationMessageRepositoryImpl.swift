import Combine

class ConversationMessageRepositoryImpl: ConversationMessageRepository {
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    private let conversationsMessagePublisher = CurrentValueSubject<[String: ConversationMessage], Never>([:])
    var conversationsMessage: AnyPublisher<[String: ConversationMessage], Never> {
        conversationsMessagePublisher.eraseToAnyPublisher()
    }
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        conversationRepository: ConversationRepository,
        messageRepository: MessageRepository
    ) {
        self.conversationRepository = conversationRepository
        self.messageRepository = messageRepository
        listen()
    }
    
    private func listen() {
        conversationRepository.conversations
            .map { Array($0.values) }
            .flatMap(self.messagesPublisher)
            .sink { [weak self] conversationMessage in
                guard let conversationMessage = conversationMessage else {
                    self?.conversationsMessagePublisher.value.removeAll()
                    return
                }
                self?.conversationsMessagePublisher.value[conversationMessage.conversation.id] = conversationMessage
            }
            .store(in: &cancellables)
    }
    
    private func messagesPublisher(from conversations: [Conversation]) -> AnyPublisher<ConversationMessage?, Never> {
        guard !conversations.isEmpty else {
            return Just(nil).eraseToAnyPublisher()
        }

        let publishers = conversations.map { conversation in
            let initial = getLastMessageFuture(conversation: conversation)
            let updates = listenMessagePublisher(conversation: conversation)
            return initial.append(updates).eraseToAnyPublisher()
        }

        return Publishers.MergeMany(publishers)
            .map { Optional($0) }
            .eraseToAnyPublisher()
    }
    
    private func getLastMessageFuture(conversation: Conversation) -> Future<ConversationMessage, Never> {
        Future<ConversationMessage, Never> { promise in
            Task {
                let message = await self.messageRepository.getLastMessage(conversationId: conversation.id)
                promise(.success(ConversationMessage(conversation: conversation, lastMessage: message)))
            }
        }
    }
    
    private func listenMessagePublisher(conversation: Conversation) -> AnyPublisher<ConversationMessage, Never> {
        messageRepository.messagePublisher
            .compactMap { change in
                change.inserted.first(where: { $0.conversationId == conversation.id }) ??
                change.updated.first(where: { $0.conversationId == conversation.id })
            }
            .map { message in
                ConversationMessage(conversation: conversation, lastMessage: message)
            }
            .eraseToAnyPublisher()
    }
}
