import Foundation
import Combine

class MockConversationRepository: ConversationRepository {
    var conversationChanges: AnyPublisher<CoreDataChange<Conversation>, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    func getLocalConversations() async throws -> [Conversation] { [] }
    
    func getLocalConversation(interlocutorId: String) async throws -> Conversation? { nil }
    
    func fetchRemoteConversations(userId: String) -> AnyPublisher<Conversation, any Error> {
        Empty()
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createLocalConversation(conversation: Conversation) async throws {}
    
    func createRemoteConversation(conversation: Conversation, userId: String) async throws {}
    
    func updateLocalConversation(conversation: Conversation) async throws {}
    
    func updateConversationDeleteTime(conversation: Conversation, currentUserId: String) async throws {}
    
    func upsertLocalConversation(conversation: Conversation) async throws {}
    
    func deleteLocalConversations() async throws {}
    
    func deleteConversation(conversation: Conversation, userId: String, deleteTime: Date) async throws {}
    
    func stopListenConversations() {}
}
