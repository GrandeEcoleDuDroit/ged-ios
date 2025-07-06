import Combine

class GetUnreadConversationsCountUseCase {
    private let conversationMessageRepository: ConversationMessageRepository
    private let userRepository: UserRepository
    
    init(
        conversationMessageRepository: ConversationMessageRepository,
        userRepository: UserRepository
    ) {
        self.conversationMessageRepository = conversationMessageRepository
        self.userRepository = userRepository
    }
    
    func execute() -> AnyPublisher<Int, Never> {
        userRepository.user.map { user in
            self.conversationMessageRepository.conversationsMessage
                .map { conversationMessages in
                    conversationMessages.values.count {
                        $0.lastMessage.senderId != user.id && !$0.lastMessage.seen
                    }
                }
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
}
