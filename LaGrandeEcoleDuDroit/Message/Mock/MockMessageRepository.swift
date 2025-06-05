import Foundation
import Combine

class MockMessageRepository: MessageRepository {
    private let messagesSubject = CurrentValueSubject<[Message], Never>(messagesFixture)
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
    
    func upsertLocalMessage(message: Message) async throws {
        messagesSubject.send(messagesSubject.value)
    }
    
    func deleteLocalMessages(conversationId: String) async throws {
        messagesSubject.send([])
    }
    
    func createMessage(message: Message) async throws {
        messagesSubject.send(messagesSubject.value + [message])
    }
    
    func updateSeenMessage(message: Message) async throws {
        messagesSubject.send(messagesSubject.value)
    }
    
    func deleteLocalMessages() async throws {
        messagesSubject.send([])
    }
    
    func stopListeningMessages() {
        
    }
}
