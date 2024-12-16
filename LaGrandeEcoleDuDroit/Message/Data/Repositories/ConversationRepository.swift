import Combine

protocol ConversationRepository {
    func getConversationsFromRemote(userId: String) -> AnyPublisher<Conversation, Error>
    
    func getConversationsFromLocal() -> AnyPublisher<(Conversation, User), ConversationError>
    
    func upsertLocalConversation(conversation: Conversation, interlocutor: User)
    
    func stopGettingConversations()
}
