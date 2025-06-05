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
        userRepository.user.flatMap { user in
            self.conversationMessageRepository.conversationsMessage
                .map { conversationMessages in
                    conversationMessages.count {
                        $0.lastMessage.senderId != user.id && !$0.lastMessage.seen
                    }
                }
        }.eraseToAnyPublisher()
    }
}
