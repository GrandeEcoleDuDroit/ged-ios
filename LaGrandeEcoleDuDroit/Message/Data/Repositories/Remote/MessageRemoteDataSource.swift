import Combine

class MessageRemoteDataSource {
    private let messageApi: MessageApi
    
    init(messageApi: MessageApi) {
        self.messageApi = messageApi
    }
    
    func listenMessages(conversationId: String) -> AnyPublisher<Message, Error> {
        messageApi.listenMessages(conversationId: conversationId)
            .compactMap { MessageMapper.toDomain(remoteMessage: $0) }
            .eraseToAnyPublisher()
    }
    
    func listenLastMessage(conversationId: String) -> AnyPublisher<Message?, ConversationError> {
        messageApi.listenLastMessage(conversationId: conversationId)
            .map { remoteMessage in
                guard let remoteMessage else { return nil }
                return MessageMapper.toDomain(remoteMessage: remoteMessage)
            }.eraseToAnyPublisher()
    }
    
    func createMessage(message: Message) async throws {
        let remoteMessage = MessageMapper.toRemote(message: message)
        try await messageApi.createMessage(remoteMessage: remoteMessage)
    }
    
    func stopListeningMessages() {
        messageApi.stopListeningMessages()
    }
    
    func stopListeningLastMessages() {
        messageApi.stopListeningLastMessages()
    }
}
