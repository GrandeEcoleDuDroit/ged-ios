class RecreateConversationUseCase {
    private let conversationRepository: ConversationRepository
    
    init(conversationRepository: ConversationRepository) {
        self.conversationRepository = conversationRepository
    }
    
    func execute(conversation: Conversation, userId: String) async {
        do {
            try await conversationRepository.updateLocalConversation(conversation: conversation.copy { $0.state = .creating })
            try await conversationRepository.createRemoteConversation(conversation: conversation, userId: userId)
            try? await conversationRepository.updateLocalConversation(conversation: conversation.copy { $0.state = .created })
        } catch {
            try? await conversationRepository.updateLocalConversation(conversation: conversation.copy { $0.state = .error })
        }
    }
}
