import Combine

protocol ConversationMessageRepository {
    var conversationsMessage: AnyPublisher<[String: ConversationMessage], Never>{ get }
    
    func clear()
}
