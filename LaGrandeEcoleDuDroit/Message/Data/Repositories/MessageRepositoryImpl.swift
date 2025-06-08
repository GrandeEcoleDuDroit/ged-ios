import Combine
import Foundation

private let tag = String(describing: MessageRepositoryImpl.self)

class MessageRepositoryImpl: MessageRepository {
    private let messageLocalDataSource: MessageLocalDataSource
    private let messageRemoteDataSource: MessageRemoteDataSource
    var messagePublisher: AnyPublisher<CoreDataChange<Message>, Never>
    
    init(
        messageLocalDataSource: MessageLocalDataSource,
        messageRemoteDataSource: MessageRemoteDataSource
    ) {
        self.messageLocalDataSource = messageLocalDataSource
        self.messageRemoteDataSource = messageRemoteDataSource
        messagePublisher = messageLocalDataSource.listenDataChange().eraseToAnyPublisher()
    }

    func getMessages(conversationId: String, offset: Int) async -> [Message] {
        (try? await messageLocalDataSource.getMessages(conversationId: conversationId, offset: offset)) ?? []
    }
    
    func getLastMessage(conversationId: String) async -> Message? {
        try? await messageLocalDataSource.getLastMessage(conversationId: conversationId)
    }
    
    func getLastMessageDate(conversationId: String) async -> Date? {
        try? await messageLocalDataSource.getLastMessage(conversationId: conversationId)?.date
    }
    
    func fetchRemoteMessages(conversationId: String, offsetTime: Date?) -> AnyPublisher<Message, Error> {
        messageRemoteDataSource.listenMessages(conversationId: conversationId, offsetTime: offsetTime)
    }
    
    func createMessage(message: Message) async throws {
        try await handleNetworkException(
            block: {
                try? await messageLocalDataSource.insertMessage(message: message)
                try await messageRemoteDataSource.createMessage(message: message)
            },
            tag: tag,
            message: "Failed to create message"
        )
    }
    
    func updateLocalMessage(message: Message) async {
        try? await messageLocalDataSource.updateMessage(message: message)
    }
        
    func updateSeenMessages(conversationId: String, userId: String) async throws {
        let unreadMessages = (try? await messageLocalDataSource.getUnreadMessagesByUser(conversationId: conversationId, userId: userId)) ?? []
        try? await messageLocalDataSource.updateSeenMessages(conversationId: conversationId, userId: userId)
        try await handleNetworkException(
            block: {
                for message in unreadMessages {
                    try? await messageRemoteDataSource.updateSeenMessage(message: message.with(seen: true))
                }
            },
            tag: tag,
            message: "Failed to update seen messages"
        )
    }
    
    func updateSeenMessage(message: Message) async throws {
        try? await messageLocalDataSource.updateMessage(message: message.with(seen: true))
        try await handleNetworkException(
            block: { try? await messageRemoteDataSource.updateSeenMessage(message: message.with(seen: true)) },
            tag: tag,
            message: "Failed to update seen messages"
        )
    }
    
    func upsertLocalMessage(message: Message) async {
        try? await messageLocalDataSource.upsertMessage(message: message)
    }
    
    func deleteLocalMessages(conversationId: String) async {
        try? await messageLocalDataSource.deleteMessages(conversationId: conversationId)
    }
    
    func deleteLocalMessages() async {
        try? await messageLocalDataSource.deleteMessages()
    }
    
    func stopListeningMessages() {
        messageRemoteDataSource.stopListeningMessages()
    }
}
