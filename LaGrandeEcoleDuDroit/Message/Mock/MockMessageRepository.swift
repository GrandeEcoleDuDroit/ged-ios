import Foundation
import Combine

class MockMessageRepository: MessageRepository {
    private let messagesSubject = CurrentValueSubject<[Message], Never>(messagesFixture)
    
    var messagePublisher: AnyPublisher<CoreDataChange<Message>, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    func getMessages(conversationId: String) -> AnyPublisher<Message, Never> {
        messagesSubject
            .compactMap { $0.first }
            .eraseToAnyPublisher()
    }
    
    func getMessages(conversationId: String) async throws -> [Message] {
        messagesFixture
    }
    
    func fetchRemoteMessages(conversationId: String, offsetTime: Date?) -> AnyPublisher<Message, Error> {
        messagesSubject.map(\.first!)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func upsertLocalMessage(message: Message) {
        messagesSubject.send(messagesSubject.value)
    }
    
    func deleteLocalMessages(conversationId: String) {
        messagesSubject.send([])
    }
    
    func createMessage(message: Message) async throws {
        messagesSubject.send(messagesSubject.value + [message])
    }
    
    func updateSeenMessages(conversationId: String, userId: String) async throws {}
    
    func updateSeenMessage(message: Message) async throws {}
        
    func deleteLocalMessages() {
        messagesSubject.send([])
    }
    
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
