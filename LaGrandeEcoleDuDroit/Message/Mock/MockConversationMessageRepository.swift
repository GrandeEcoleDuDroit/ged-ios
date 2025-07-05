import Combine

class MockConversationMessageRepository: ConversationMessageRepository {
    var conversationsMessage: AnyPublisher<[String : ConversationMessage], Never> {
        Empty().eraseToAnyPublisher()
    }
    
    func clear() {}
}
