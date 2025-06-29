import Foundation
import Combine

class MockConversationRepository: ConversationRepository {
    private let conversationsSubject = CurrentValueSubject<CoreDataChange<Conversation>, Never>(CoreDataChange(inserted: [], updated: [], deleted: []))
    var conversationChanges: AnyPublisher<CoreDataChange<Conversation>, Never> {
        conversationsSubject.eraseToAnyPublisher()
    }
    
    func getConversations() async throws -> [Conversation] {
        conversationsFixture
    }
    
    func getConversation(interlocutorId: String) async throws -> Conversation? {
        conversationFixture
    }
    
    func fetchRemoteConversations(userId: String) -> AnyPublisher<Conversation, any Error> {
        Just(conversationFixture)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createLocalConversation(conversation: Conversation) async throws {
        conversationsSubject.send(
            CoreDataChange(
                inserted: [conversation],
                updated: [],
                deleted: []
            )
        )
    }
    
    func createRemoteConversation(conversation: Conversation, userId: String) async throws {
        conversationsSubject.send(
            CoreDataChange(
                inserted: [conversation],
                updated: [],
                deleted: []
            )
        )
    }
    
    func updateLocalConversation(conversation: Conversation) async throws {
        conversationsSubject.send(
            CoreDataChange(
                inserted: [],
                updated: [conversation],
                deleted: []
            )
        )
    }
    
    func upsertLocalConversation(conversation: Conversation) async throws {
        conversationsSubject.send(
            CoreDataChange(
                inserted: [conversation],
                updated: [],
                deleted: []
            )
        )
    }
    
    func deleteLocalConversations() async throws {
        conversationsSubject.send(
            CoreDataChange(
                inserted: [],
                updated: [],
                deleted: conversationsFixture
            )
        )
    }
    
    func deleteConversation(conversation: Conversation, userId: String, deleteTime: Date) async throws {
        conversationsSubject.send(
            CoreDataChange(
                inserted: [],
                updated: [],
                deleted: [conversation]
            )
        )
    }
    
    func stopListenConversations() {}
}
