class DeleteConversationUseCase {
    private let userConversationRepository: UserConversationRepository

    init(userConversationRepository: UserConversationRepository) {
        self.userConversationRepository = userConversationRepository
    }
    
    func execute(conversationId: String) async throws {
        try await userConversationRepository.deleteConversation(conversationId: conversationId)
    }
}
