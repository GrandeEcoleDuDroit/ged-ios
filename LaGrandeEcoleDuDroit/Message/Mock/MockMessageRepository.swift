import Foundation
import Combine

class MockMessageRepository: MessageRepository {
    func getMessages(conversationId: String) -> AnyPublisher<Message, any Error> {
        Just(messagesFixture.last!).setFailureType(to: (any Error).self).eraseToAnyPublisher()
    }
    
    func getLastMessage(conversationId: String) -> AnyPublisher<Message?, ConversationError> {
        let lastMessageFixture = lastMessagesFixture.first(where: { $0.conversationId == conversationId })
        return Just(lastMessageFixture)
            .setFailureType(to: ConversationError.self)
            .eraseToAnyPublisher()
    }
    
    func createMessage(message: Message) async throws {
        // No implementation needed
    }
    
    func updateMessageState(messageId: String, messageState: MessageState) async throws {
        // No implementation needed
    }

    func stopGettingMessages() {
        // No implementation needed
    }
    
    func stopGettingLastMessages() {
        // No implementation needed
    }
}
