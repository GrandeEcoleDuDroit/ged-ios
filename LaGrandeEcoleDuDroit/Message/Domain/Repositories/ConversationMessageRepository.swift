import Combine

protocol ConversationMessageRepository {
    var conversationsMessage: AnyPublisher<[ConversationMessage], Never> { get }
}
