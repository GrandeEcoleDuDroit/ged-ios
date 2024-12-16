import Combine

class MessageRemoteDataSource {
    private let messageApi: MessageApi
    
    init(messageApi: MessageApi) {
        self.messageApi = messageApi
    }
    
    func listenMessages(conversationId: String) -> AnyPublisher<[Message], Error> {
        messageApi.listenMessages(conversationId: conversationId)
            .map { remoteMessages in
                remoteMessages.map { MessageMapper.toDomain(remoteMessage: $0) }
            }.eraseToAnyPublisher()
    }
    
    func listenLastMessage(conversationId: String) -> AnyPublisher<Message?, ConversationError> {
        messageApi.listenLastMessage(conversationId: conversationId)
            .map { remoteMessage in
                guard let remoteMessage else { return nil }
                return MessageMapper.toDomain(remoteMessage: remoteMessage)
            }.eraseToAnyPublisher()
    }
    
    func stopListeningLastMessages() {
        messageApi.stopListeningLastMessages()
    }
}
