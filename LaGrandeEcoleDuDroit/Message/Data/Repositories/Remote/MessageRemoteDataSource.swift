import Combine
import FirebaseCore

class MessageRemoteDataSource {
    private let messageApi: MessageApi
    
    init(messageApi: MessageApi) {
        self.messageApi = messageApi
    }
    
    func listenMessages(conversationId: String, offsetTime: Date?) -> AnyPublisher<Message, Error> {
        let offsetTime: Timestamp? = offsetTime.map { Timestamp(date: $0) }
        
        return messageApi.listenMessages(conversationId: conversationId, offsetTime: offsetTime)
            .map { $0.toMessage() }
            .eraseToAnyPublisher()
    }
    
    func createMessage(message: Message) async throws {
        try await messageApi.createMessage(remoteMessage: message.toRemote())
    }
    
    func updateSeenMessage(message: Message) async throws {
        try await messageApi.updateSeenMessage(remoteMessage: message.toRemote())
    }
    
    func stopListeningMessages() {
        messageApi.stopListeningMessages()
    }
}
