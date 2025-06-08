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
                    conversationMessages.values.filter {
                        guard let lastMessage = $0.lastMessage else { return false }
                        return lastMessage.senderId != user.id && !lastMessage.seen
                    }.count
                }
        }.eraseToAnyPublisher()
    }
}
