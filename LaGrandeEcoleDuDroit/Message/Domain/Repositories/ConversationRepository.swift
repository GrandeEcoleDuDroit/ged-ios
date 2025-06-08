import Combine
import Foundation

protocol ConversationRepository {
    var conversations: AnyPublisher<[String: Conversation], Never> { get }
    
    func getConversations() async -> [Conversation]
    
    func getConversation(interlocutorId: String) async -> Conversation?
    
    func fetchRemoteConversations(userId: String, offsetTime: Date?) -> AnyPublisher<Conversation, Error>
    
    func createConversation(conversation: Conversation, userId: String) async throws
    
    func updateLocalConversation(conversation: Conversation) async
    
    func upsertLocalConversation(conversation: Conversation) async
    
    func deleteConversation(conversation: Conversation, userId: String) async throws
    
    func deleteLocalConversations() async
        
    func getLastConversationDate() async -> Date?
    
    func stopListenConversations()
}
