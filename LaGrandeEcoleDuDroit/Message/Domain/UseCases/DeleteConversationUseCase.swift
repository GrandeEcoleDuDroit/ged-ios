class DeleteConversationUseCase {
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    
    init(conversationRepository: ConversationRepository, messageRepository: MessageRepository) {
        self.conversationRepository = conversationRepository
        self.messageRepository = messageRepository
    }
    
    func execute(conversation: Conversation, userId: String) {
        Task {
            await messageRepository.deleteLocalMessages(conversationId: conversation.id)
            try? await conversationRepository.deleteConversation(conversation: conversation, userId: userId)
        }
    }
}
