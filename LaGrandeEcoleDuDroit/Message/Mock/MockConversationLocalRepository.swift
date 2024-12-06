import Foundation
import Combine

class MockConversationLocalRepository: ConversationLocalRepository {
    @Published private var _conversations: [Conversation] = conversationsFixture
    var conversations: AnyPublisher<[Conversation], Never> {
        $_conversations.eraseToAnyPublisher()
    }
}
