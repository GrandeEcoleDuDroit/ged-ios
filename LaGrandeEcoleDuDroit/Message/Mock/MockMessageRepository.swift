import Foundation
import Combine

class MockMessageRepository: MessageRepository {
    var messageChanges: AnyPublisher<CoreDataChange<Message>, Never> { Empty().eraseToAnyPublisher() }

    func getMessages(conversationId: String, offset: Int, limit: Int) async throws -> [Message] { [] }
    
    func getLastMessage(conversationId: String) async throws -> Message? { nil }
    
    func getUnsentMessages() async throws -> [Message] { [] }
    
    func fetchRemoteMessages(userId: String, conversation: Conversation, offsetTime: Date?) -> AnyPublisher<Message, Error> {
        Empty().eraseToAnyPublisher()
    }
    
    func createLocalMessage(message: Message) async throws {}
        
    func createRemoteMessage(message: Message) async throws {}
    
    func updateLocalMessage(message: Message) async throws {}
        
    func setMessagesSeen(conversationId: String, currentUserId: String) async throws {}
    
    func setMessageSeen(message: Message) async throws {}
    
    func updateMessageVisibility(message: Message, currentUserId: String, visible: Bool) async throws {}
    
    func upsertLocalMessage(message: Message) async throws {}
        
    func deleteLocalMessage(message: Message) async throws {}
        
    func deleteLocalMessages(conversationId: String) async throws {}
    
    func deleteLocalMessages() async throws {}
            
    func stopListeningMessages() {}
    
    func reportMessage(report: MessageReport) async throws {}
}
