import Foundation
import Combine

class MockConversationRepository: ConversationRepository {
    private let conversationsSubject = CurrentValueSubject<[String: Conversation], Never>([:])
    var conversations: AnyPublisher<[String: Conversation], Never> {
        conversationsSubject.eraseToAnyPublisher()
    }
    
    func getConversations() async -> [Conversation] {
        conversationsFixture
    }
    
    func getConversation(interlocutorId: String) async -> Conversation? {
        conversationsSubject.value.values.first
    }
    
    func fetchRemoteConversations(userId: String, offsetTime: Date?) -> AnyPublisher<Conversation, any Error> {
        conversationsSubject.eraseToAnyPublisher()
            .compactMap { $0.values.first }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createConversation(conversation: Conversation, userId: String) async throws {
        conversationsSubject.value[conversation.id] = conversation
    }
    
    func updateLocalConversation(conversation: Conversation) async {
        conversationsSubject.value[conversation.id] = conversation
    }
    
    func upsertLocalConversation(conversation: Conversation) async {
        conversationsSubject.value[conversation.id] = conversation
    }
    
    func deleteLocalConversations() async {
        conversationsSubject.value.removeAll()
    }
    
    func deleteConversation(conversation: Conversation, userId: String) async throws {
        conversationsSubject.value[conversation.id] = nil
    }
    
    func stopListenConversations() {}
    
    func getLastConversationDate() async -> Date? {
        Date()
    }
}
