import Combine
import Foundation

protocol ConversationRepository {
    var conversationChanges: AnyPublisher<CoreDataChange<Conversation>, Never> { get }
    
    func getConversations() async -> [Conversation]
    
    func getConversation(interlocutorId: String) async -> Conversation?
    
    func fetchRemoteConversations(userId: String) -> AnyPublisher<Conversation, Error>
    
    func createConversation(conversation: Conversation, userId: String) async throws
    
    func updateLocalConversation(conversation: Conversation) async
    
    func upsertLocalConversation(conversation: Conversation) async
    
    func deleteConversation(conversation: Conversation, userId: String) async throws
    
    func deleteLocalConversations() async
    
    func stopListenConversations()
}
