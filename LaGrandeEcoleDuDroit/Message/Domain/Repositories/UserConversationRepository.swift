import Combine

protocol UserConversationRepository {
    func getUserConversations() -> AnyPublisher<ConversationUser, ConversationError>
    
    func createConversation(conversationUser: ConversationUser) async throws
        
    func stopGettingUserConversations()
}
