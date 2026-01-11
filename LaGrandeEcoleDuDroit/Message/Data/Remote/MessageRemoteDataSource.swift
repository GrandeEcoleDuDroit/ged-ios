import Combine
import FirebaseCore

class MessageRemoteDataSource {
    private let tag = String(describing: MessageRemoteDataSource.self)
    private let messageApi: MessageApi
    
    init(messageApi: MessageApi) {
        self.messageApi = messageApi
    }
    
    func listenMessages(userId: String, conversation: Conversation, offsetTime: Date?) -> AnyPublisher<Message, Error> {
        let offsetTime: Timestamp? = offsetTime.map { Timestamp(date: $0) }
        return messageApi.listenMessages(userId: userId, conversation: conversation, offsetTime: offsetTime)
            .map { $0.toMessage(userId: userId) }
            .eraseToAnyPublisher()
    }
    
    func createMessage(message: Message) async throws {
        try await messageApi.createMessage(remoteMessage: message.toRemote())
    }
    
    func setMessagesSeen(message: Message) async throws {
        try await messageApi.setMessageSeen(conversationId: message.conversationId, messageId: message.id)
    }
    
    func updateMessageVisibility(message: Message, userId: String, visible: Bool) async throws {
        try await messageApi.updateMessageVisibility(remoteMessage: message.toRemote(), userId: userId, visible: visible)
    }
    
    func stopListeningMessages() {
        messageApi.stopListeningMessages()
    }
    
    func reportMessage(report: MessageReport) async throws {
        try await messageApi.reportMessage(report: report)
    }
}
