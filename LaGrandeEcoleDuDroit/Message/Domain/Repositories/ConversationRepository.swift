import Combine

protocol ConversationRepository {
    var conversations: AnyPublisher<[Conversation], Never> { get }
    
    func getConversation(interlocutorId: String) async -> Conversation?
    
    func fetchRemoteConversations(userId: String) -> AnyPublisher<Conversation, Error>
    
    func createConversation(conversation: Conversation, userId: String) async throws
    
    func updateLocalConversation(conversation: Conversation) async throws
    
    func upsertLocalConversation(conversation: Conversation) async throws
    
    func deleteConversation(conversationId: String, userId: String) async throws
    
    func deleteLocalConversations() async throws
    
    func stopListenConversations()
}
