import Foundation
import Combine

class MockConversationRepository: ConversationRepository {
    private let conversationsSubject = CurrentValueSubject<[Conversation], Never>(conversationsFixture)
    var conversations: AnyPublisher<[Conversation], Never> {
        conversationsSubject.eraseToAnyPublisher()
    }
    
    func getConversation(interlocutorId: String) async -> Conversation? {
        conversationsSubject.value.first
    }
    
    func fetchRemoteConversations(userId: String) -> AnyPublisher<Conversation, any Error> {
        conversationsSubject.eraseToAnyPublisher().map { $0.first! }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createConversation(conversation: Conversation, userId: String) async throws {
        conversationsSubject.value.append(conversation)
    }
    
    func updateLocalConversation(conversation: Conversation) async throws {
        conversationsSubject.value[conversationsSubject.value.firstIndex(of: conversation)!] = conversation
    }
    
    func upsertLocalConversation(conversation: Conversation) async throws {
        conversationsSubject.value.append(conversation)
    }
    
    func deleteConversation(conversationId: String, userId: String) async throws {
        conversationsSubject.value.removeAll { $0.id == conversationId }
    }
    
    func deleteLocalConversations() async {
        conversationsSubject.value.removeAll()
    }
    
    func stopListenConversations() {
        
    }
}
