import Combine

protocol MessageRepository {
    func getMessages(conversationId: String) -> AnyPublisher<Message, Error>
    
    func getLastMessage(conversationId: String) -> AnyPublisher<Message?, ConversationError>
    
    func createMessage(message: Message) async throws
    
    func updateMessageState(messageId: String, messageState: MessageState) async throws
    
    func stopGettingLastMessages()
}
