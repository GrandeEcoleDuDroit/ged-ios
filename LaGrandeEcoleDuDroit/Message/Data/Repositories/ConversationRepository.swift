import Combine

protocol ConversationRepository {
    func getConversationsFromRemote(userId: String) -> AnyPublisher<Conversation, Error>
    
    func getConversationsFromLocal() -> AnyPublisher<(Conversation, User), ConversationError>
    
    func upsertLocalConversation(conversation: Conversation, interlocutor: User) throws
    
    func createConversation(
        conversation: Conversation,
        interlocutor: User,
        currentUser: User
    ) async throws
    
    func deleteConversation(conversationId: String) async throws
    
    func stopGettingConversations()
}
