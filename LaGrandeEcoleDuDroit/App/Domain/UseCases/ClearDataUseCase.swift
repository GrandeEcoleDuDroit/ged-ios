class ClearDataUseCase {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    
    init(
        userRepository: UserRepository,
        conversationRepository: ConversationRepository,
        messageRepository: MessageRepository
    ) {
        self.userRepository = userRepository
        self.conversationRepository = conversationRepository
        self.messageRepository = messageRepository
    }
    
    func execute() async {
        userRepository.deleteCurrentUser()
        await messageRepository.deleteLocalMessages()
        await conversationRepository.deleteLocalConversations()
    }
}
