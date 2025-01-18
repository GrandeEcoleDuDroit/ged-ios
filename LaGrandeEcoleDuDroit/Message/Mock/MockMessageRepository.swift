import Foundation
import Combine

class MockMessageRepository: MessageRepository {
    private let _messages = CurrentValueSubject<[Message], any Error>(messagesFixture)
    
    func getMessages(conversationId: String) -> AnyPublisher<Message, any Error> {
        _messages
            .flatMap { messages in
                let filteredMessages = messages.filter { $0.conversationId == conversationId }
                return Publishers.Sequence(sequence: filteredMessages)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        }
        
        func getLastMessage(conversationId: String) -> AnyPublisher<Message?, ConversationError> {
            Publishers.Sequence(sequence: lastMessagesFixture.filter({ $0.conversationId == conversationId }))
                .eraseToAnyPublisher()
        }
    
    func createMessage(message: Message) async throws {
        _messages.value.append(message)
    }
    
    func updateMessageState(messageId: String, messageState: MessageState) async throws {
        var message = _messages.value.first { $0.id == messageId }!
        message.state = messageState
        _messages.value = _messages.value.map { $0.id == messageId ? message : $0 }
    }

    func stopGettingMessages() {
        // No implementation needed
    }
    
    func stopGettingLastMessages() {
        // No implementation needed
    }
}
