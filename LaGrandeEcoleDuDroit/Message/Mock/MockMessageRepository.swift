import Foundation
import Combine

class MockMessageRepository: MessageRepository {
    var messageChanges: AnyPublisher<CoreDataChange<Message>, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    func getMessages(conversationId: String, offset: Int, limit: Int) async throws -> [Message] { [] }
    
    func getLastMessage(conversationId: String) -> Message? { nil }
    
    func getUnsentMessages() async throws -> [Message] { [] }
    
    func fetchRemoteMessages(conversation: Conversation, offsetTime: Date?) -> AnyPublisher<Message, Error> {
        Empty().eraseToAnyPublisher()
    }
    
    func createLocalMessage(message: Message) async throws {}
    
    func createRemoteMessage(message: Message) async throws {}

    func updateLocalMessage(message: Message) {}
    
    func updateSeenMessages(conversationId: String, currentUserId: String) async throws {}
    
    func updateSeenMessage(message: Message) async throws {}
    
    func upsertLocalMessage(message: Message) {}
    
    func deleteLocalMessages(conversationId: String) {}
    
    func deleteLocalMessages() {}
    
    func deleteLocalMessage(message: Message) async throws {}
            
    func stopListeningMessages() {}
    
    func reportMessage(report: MessageReport) async throws {}
}
