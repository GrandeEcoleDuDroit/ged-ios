import Combine

protocol ConversationApi {
    func listenConversations(userId: String) -> AnyPublisher<RemoteConversation, Error>
    
    func createConversation(conversationId: String, data: [String: Any]) async throws
    
    func updateConversation(conversationId: String, data: [String: Any]) async throws
        
    func stopListeningConversations()
}
