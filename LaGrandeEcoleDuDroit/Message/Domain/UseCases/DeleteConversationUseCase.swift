class DeleteConversationUseCase {
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    
    init(conversationRepository: ConversationRepository, messageRepository: MessageRepository) {
        self.conversationRepository = conversationRepository
        self.messageRepository = messageRepository
    }
    
    func execute(conversation: Conversation, userId: String) {
        Task {
            do {
                try await conversationRepository.upsertLocalConversation(conversation: conversation.with(state: .loading))
                try await conversationRepository.deleteConversation(conversationId: conversation.id, userId: userId)
                try await messageRepository.deleteLocalMessages(conversationId: conversation.id)
            } catch {
                try? await conversationRepository.upsertLocalConversation(conversation: conversation.with(state: .error))
            }
        }
    }
}
