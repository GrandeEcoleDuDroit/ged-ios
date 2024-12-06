import Combine

protocol ConversationLocalRepository {
    var conversations: AnyPublisher<[Conversation], Never> { get }
}
