import Foundation
import Combine

class MockConversationRepository: ConversationRepository {
    var conversationChanges: AnyPublisher<CoreDataChange<Conversation>, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    func getLocalConversations() async -> [Conversation] { [] }
    
    func getLocalConversation(interlocutorId: String) async -> Conversation? { nil }
    
    func getRemoteConversationsPublisher(user: User) -> AnyPublisher<RemoteConversation, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    func createLocalConversation(conversation: Conversation) async throws {}
    
    func createRemoteConversation(conversation: Conversation, userId: String) async throws {}
    
    func updateLocalConversation(conversation: Conversation) async throws {}
    
    func updateConversationEffectiveFrom(conversationId: String, currentUserId: String, effectiveFrom: Date) async throws {}
    
    func upsertLocalConversation(conversation: Conversation) async throws {}
    
    func deleteLocalConversations() async throws {}
    
    func deleteConversation(conversationId: String, userId: String, date: Date) async throws {}

    func stopListenConversations() {}
}
