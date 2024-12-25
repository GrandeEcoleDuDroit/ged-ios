import Combine

protocol ConversationApi {
    func listenConversations(userId: String) -> AnyPublisher<RemoteConversation, Error>
    
    func createConversation(remoteConversation: RemoteConversation) async throws
    
    func deleteConversation(conversationId: String) async throws
    
    func stopListeningConversations()
}
