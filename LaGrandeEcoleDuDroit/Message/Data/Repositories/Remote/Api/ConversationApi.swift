import Combine
import FirebaseCore

protocol ConversationApi {
    func listenConversations(userId: String, notInConversationIds: [String]) -> AnyPublisher<RemoteConversation, Error>
    
    func createConversation(conversationId: String, data: [String: Any]) async throws
    
    func updateConversation(conversationId: String, data: [String: Any]) async throws
        
    func stopListeningConversations()
}
