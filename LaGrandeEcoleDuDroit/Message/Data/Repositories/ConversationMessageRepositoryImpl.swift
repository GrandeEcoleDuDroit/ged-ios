import Combine

class ConversationMessageRepositoryImpl: ConversationMessageRepository {
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    private let conversationsMessagePublisher = CurrentValueSubject<[ConversationMessage], Never>([])
    var conversationsMessage: AnyPublisher<[ConversationMessage], Never> {
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
            .flatMap { conversations -> AnyPublisher<[ConversationMessage], Never> in
                let publishers = conversations.map { conversation in
                    self.messageRepository
                        .getMessages(conversationId: conversation.id)
                        .map { message in
                            ConversationMessage(conversation: conversation, lastMessage: message)
                        }
                }
                
                return Publishers.MergeMany(publishers)
                    .collect()
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] conversationMessages in
                self?.conversationsMessagePublisher.send(conversationMessages)
            }
            .store(in: &cancellables)
    }

}
