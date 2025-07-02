import Combine

class MockConversationMessageRepository: ConversationMessageRepository {
    private let conversationsMessageSubject = CurrentValueSubject<[String : ConversationMessage], Never>([:])
    var conversationsMessage: AnyPublisher<[String : ConversationMessage], Never> {
        conversationsMessageSubject.eraseToAnyPublisher()
    }
    
    func clear() {}
}
