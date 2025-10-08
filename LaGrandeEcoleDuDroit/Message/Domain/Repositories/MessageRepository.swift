import Combine
import Foundation

protocol MessageRepository {
    var messageChanges: AnyPublisher<CoreDataChange<Message>, Never> { get }

    func getMessages(conversationId: String, offset: Int, limit: Int) async throws -> [Message]
    
    func getLastMessage(conversationId: String) async throws -> Message?
    
    func getUnsentMessages() async throws -> [Message]
    
    func fetchRemoteMessages(conversation: Conversation, offsetTime: Date?) -> AnyPublisher<Message, Error>
    
    func createLocalMessage(message: Message) async throws
        
    func createRemoteMessage(message: Message) async throws
    
    func updateLocalMessage(message: Message) async throws
    
    func updateSeenMessages(conversationId: String, userId: String) async throws
    
    func updateSeenMessage(message: Message) async throws
        
    func upsertLocalMessage(message: Message) async throws
        
    func deleteLocalMessage(message: Message) async throws
        
    func deleteLocalMessages(conversationId: String) async throws
    
    func deleteLocalMessages() async throws
            
    func stopListeningMessages()
    
    func reportMessage(report: MessageReport) async throws
}
