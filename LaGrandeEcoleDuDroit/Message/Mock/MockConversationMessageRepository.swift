import Combine

class MockConversationMessageRepository: ConversationMessageRepository {
    private let conversationsMessageSubject = CurrentValueSubject<[String : ConversationMessage], Never>([:])
    var conversationsMessage: AnyPublisher<[String : ConversationMessage], Never> {
        conversationsMessageSubject.eraseToAnyPublisher()
    }
    
    func deleteConversationMessage(conversationId: String) {
        conversationsMessageSubject.value.removeValue(forKey: conversationId)
    }
    
    func deleteAll() {
        conversationsMessageSubject.value.removeAll()
    }
}
