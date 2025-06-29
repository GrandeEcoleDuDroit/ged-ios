import Foundation
import Combine

class MockMessageRepository: MessageRepository {
    private let messagesSubject = PassthroughSubject<Message, Never>()
    
    var messageChanges: AnyPublisher<CoreDataChange<Message>, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    func getMessages(conversationId: String) async throws -> [Message] {
        messagesFixture
    }
    
    func fetchRemoteMessages(conversation: Conversation, offsetTime: Date?) -> AnyPublisher<[Message], Error> {
        messagesSubject
            .map { [$0] }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createLocalMessage(message: Message) async throws {
        
    }
    
    func upsertLocalMessage(message: Message) {
        messagesSubject.send(messageFixture)
    }
    
    func upsertLocalMessages(messages: [Message]) {
        messages.forEach { message in
            messagesSubject.send(message)
        }
    }
    
    func deleteLocalMessages(conversationId: String) {}
    
    func createRemoteMessage(message: Message) async throws {}
    
    func updateSeenMessages(conversationId: String, userId: String) async throws {}
    
    func updateSeenMessage(message: Message) async throws {}
        
    func deleteLocalMessages() {}
    
    func stopListeningMessages() {}
    
    func listen() -> AnyPublisher<CoreDataChange<Message>, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    func getMessages(conversationId: String, offset: Int) -> [Message] {
        messagesFixture
    }
    
    func getLastMessage(conversationId: String) -> Message? {
        messageFixture
    }
    
    func getLastMessageDate(conversationId: String) async -> Date? {
        Date()
    }
    
    func updateLocalMessage(message: Message) {}
}
