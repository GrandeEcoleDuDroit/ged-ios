import Foundation
import Combine

class MockMessageRepository: MessageRepository {
    func getMessages(conversationId: String) -> AnyPublisher<[Message], any Error> {
        Just(messagesFixture).setFailureType(to: (any Error).self).eraseToAnyPublisher()
    }
    
    func getLastMessage(conversationId: String) -> AnyPublisher<Message?, ConversationError> {
        let lastMessageFixture = lastMessagesFixture.first(where: { $0.conversationId == conversationId })
        return Just(lastMessageFixture)
            .setFailureType(to: ConversationError.self)
            .eraseToAnyPublisher()
    }

    func stopGettingLastMessages() {
        // No implementation needed
    }
}
