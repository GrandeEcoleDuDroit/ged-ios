import Combine
import Foundation

protocol ConversationRepository {
    var conversationChanges: AnyPublisher<CoreDataChange<Conversation>, Never> { get }
    
    func getLocalConversations() async throws -> [Conversation]
    
    func getLocalConversation(interlocutorId: String) async throws -> Conversation?
    
    func fetchRemoteConversations(userId: String) -> AnyPublisher<Conversation, Error>
    
    func createLocalConversation(conversation: Conversation) async throws
    
    func createRemoteConversation(conversation: Conversation, userId: String) async throws
    
    func updateLocalConversation(conversation: Conversation) async throws
    
    func updateConversationDeleteTime(conversation: Conversation, currentUserId: String) async throws
    
    func upsertLocalConversation(conversation: Conversation) async throws
    
    func deleteConversation(conversation: Conversation, userId: String, deleteTime: Date) async throws
    
    func deleteLocalConversations() async throws
    
    func stopListenConversations()
}
