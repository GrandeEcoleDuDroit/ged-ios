import Foundation
import Combine

class MockMessageRepository: MessageRepository {
    private let messagesSubject = PassthroughSubject<Message, Never>()
    
    var messageChanges: AnyPublisher<CoreDataChange<Message>, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    func getMessages(conversationId: String, offset: Int) async throws -> [Message] {
        messagesFixture
    }
    
    func getLastMessage(conversationId: String) -> Message? {
        messageFixture
    }
    
    func getUnsentMessages() async throws -> [Message] {
        messagesFixture
    }
    
    func fetchRemoteMessages(conversation: Conversation, offsetTime: Date?) -> AnyPublisher<[Message], Error> {
        messagesSubject
            .map { [$0] }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func createLocalMessage(message: Message) async throws {}
    
    func createRemoteMessage(message: Message) async throws {}

    func updateLocalMessage(message: Message) {}
    
    func updateSeenMessages(conversationId: String, userId: String) async throws {}
    
    func updateSeenMessage(message: Message) async throws {}
    
    func upsertLocalMessage(message: Message) {
        messagesSubject.send(messageFixture)
    }
    
    func upsertLocalMessages(messages: [Message]) {
        messages.forEach { message in
            messagesSubject.send(message)
        }
    }
    
    func deleteLocalMessages(conversationId: String) {}
    
    func deleteLocalMessages() {}
    
    func deleteLocalMessage(message: Message) async throws {}
            
    func stopListeningMessages() {}
}
