import Combine
import Foundation

protocol MessageRepository {
    var messageChanges: AnyPublisher<CoreDataChange<Message>, Never> { get }

    func getMessages(conversationId: String, offset: Int) async -> [Message]
    
    func getLastMessage(conversationId: String) async -> Message?
    
    func fetchRemoteMessages(conversation: Conversation, offsetTime: Date?) -> AnyPublisher<Message, Error>
        
    func createMessage(message: Message) async throws
    
    func updateLocalMessage(message: Message) async
    
    func updateSeenMessages(conversationId: String, userId: String) async throws
    
    func updateSeenMessage(message: Message) async throws
        
    func upsertLocalMessage(message: Message) async
        
    func deleteLocalMessages(conversationId: String) async
    
    func deleteLocalMessages() async
    
    func getLastMessageDate(conversationId: String) async -> Date?
    
    func stopListeningMessages()
}
