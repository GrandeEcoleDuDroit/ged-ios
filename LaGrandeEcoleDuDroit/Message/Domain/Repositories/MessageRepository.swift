import Combine

protocol MessageRepository {
    func getMessages(conversationId: String) -> AnyPublisher<[Message], Error>
    
    func getLastMessage(conversationId: String) -> AnyPublisher<Message?, ConversationError>
    
    func stopGettingLastMessages()
}
