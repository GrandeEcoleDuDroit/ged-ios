import Combine

class MessageRepositoryImpl: MessageRepository {
    private let messageLocalDataSource: MessageLocalDataSource
    private let messageRemoteDataSource: MessageRemoteDataSource
    
    init(
        messageLocalDataSource: MessageLocalDataSource,
        messageRemoteDataSource: MessageRemoteDataSource
    ) {
        self.messageLocalDataSource = messageLocalDataSource
        self.messageRemoteDataSource = messageRemoteDataSource
    }
    
    func getMessages(conversationId: String) -> AnyPublisher<[Message], Error> {
        messageRemoteDataSource.listenMessages(conversationId: conversationId)
    }
    
    func getLastMessage(conversationId: String) -> AnyPublisher<Message?, ConversationError> {
        messageRemoteDataSource.listenLastMessage(conversationId: conversationId)
    }
    
    func stopGettingLastMessages() {
        messageRemoteDataSource.stopListeningLastMessages()
    }
}
