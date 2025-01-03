class CreateConversationUseCase {
    private let userConversationRepository: UserConversationRepository
    
    init(userConversationRepository: UserConversationRepository) {
        self.userConversationRepository = userConversationRepository
    }
    
    func execute(conversationUI: ConversationUI) async throws {
        let conversationUser = ConversationMapper.toConversationUser(conversationUI:conversationUI)
        try await userConversationRepository.createConversation(conversationUser: conversationUser)
        try await userConversationRepository.updateConversation(conversationUser: conversationUser.with(state: .created))
    }
}
