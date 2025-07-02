class ClearDataUseCase {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    private let conversationMessageRepository: ConversationMessageRepository
    
    init(
        userRepository: UserRepository,
        conversationRepository: ConversationRepository,
        messageRepository: MessageRepository,
        conversationMessageRepository: ConversationMessageRepository
    ) {
        self.userRepository = userRepository
        self.conversationRepository = conversationRepository
        self.messageRepository = messageRepository
        self.conversationMessageRepository = conversationMessageRepository
    }
    
    func execute() async {
        userRepository.deleteCurrentUser()
        try? await messageRepository.deleteLocalMessages()
        try? await conversationRepository.deleteLocalConversations()
        conversationMessageRepository.clear()
    }
}
