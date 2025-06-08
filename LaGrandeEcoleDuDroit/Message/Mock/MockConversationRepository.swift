import Foundation
import Combine

class MockConversationRepository: ConversationRepository {
    private let conversationsSubject = CurrentValueSubject<CoreDataChange<Conversation>, Never>(CoreDataChange(inserted: [], updated: [], deleted: []))
    var conversationChanges: AnyPublisher<CoreDataChange<Conversation>, Never> {
        conversationsSubject.eraseToAnyPublisher()
    }
    
    func getConversations() async -> [Conversation] {
        conversationsFixture
    }
    
    func getConversation(interlocutorId: String) async -> Conversation? {
        conversationFixture
    }
    
    func fetchRemoteConversations(userId: String, offsetTime: Date?) -> AnyPublisher<Conversation, any Error> {
        Just(conversationFixture)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createConversation(conversation: Conversation, userId: String) async throws {}
    
    func updateLocalConversation(conversation: Conversation) async {}
    
    func upsertLocalConversation(conversation: Conversation) async {}
    
    func deleteLocalConversations() async {}
    
    func deleteConversation(conversation: Conversation, userId: String) async throws {}
    
    func stopListenConversations() {}
    
    func getLastConversationDate() async -> Date? {
        Date()
    }
}
