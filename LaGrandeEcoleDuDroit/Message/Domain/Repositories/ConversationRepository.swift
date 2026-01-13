import Combine
import Foundation

protocol ConversationRepository {
    var conversationChanges: AnyPublisher<CoreDataChange<Conversation>, Never> { get }
    
    func getLocalConversations() async -> [Conversation]
    
    func getLocalConversation(interlocutorId: String) async -> Conversation?
    
    func getRemoteConversationsPublisher(user: User) -> AnyPublisher<RemoteConversation, Never>

    func createLocalConversation(conversation: Conversation) async throws
    
    func createRemoteConversation(conversation: Conversation, userId: String) async throws
    
    func updateLocalConversation(conversation: Conversation) async throws
    
    func updateConversationEffectiveFrom(conversationId: String, currentUserId: String, effectiveFrom: Date) async throws

    func upsertLocalConversation(conversation: Conversation) async throws
    
    func deleteConversation(conversationId: String, userId: String, date: Date) async throws
    
    func deleteLocalConversation(conversationId: String) async throws

    func deleteLocalConversations() async throws
    
    func stopListenConversations()
}
