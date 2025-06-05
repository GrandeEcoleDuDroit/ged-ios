import Combine
import Foundation

protocol MessageRepository {
    func getMessages(conversationId: String) -> AnyPublisher<Message, Never>
    
    func getMessages(conversationId: String) async throws -> [Message]
    
    func fetchRemoteMessages(conversationId: String, offsetTime: Date?) -> AnyPublisher<Message, Error>
        
    func createMessage(message: Message) async throws
    
    func updateSeenMessage(message: Message) async throws
    
    func upsertLocalMessage(message: Message) async throws
        
    func deleteLocalMessages(conversationId: String) async throws
    
    func deleteLocalMessages() async throws
    
    func stopListeningMessages()
}
