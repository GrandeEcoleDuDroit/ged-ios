import Combine
import Foundation

private let tag = String(describing: MessageRepositoryImpl.self)

class MessageRepositoryImpl: MessageRepository {
    private let messageLocalDataSource: MessageLocalDataSource
    private let messageRemoteDataSource: MessageRemoteDataSource
    private var cancellables = Set<AnyCancellable>()
    private let messagePublisher = PassthroughSubject<Message, Never>()
    
    init(
        messageLocalDataSource: MessageLocalDataSource,
        messageRemoteDataSource: MessageRemoteDataSource
    ) {
        self.messageLocalDataSource = messageLocalDataSource
        self.messageRemoteDataSource = messageRemoteDataSource
    }
    
    func getMessages(conversationId: String) -> AnyPublisher<Message, Never> {
        messagePublisher.filter { $0.conversationId == conversationId }.eraseToAnyPublisher()
    }
    
    func getMessages(conversationId: String) async throws -> [Message] {
        try await messageLocalDataSource.getMessages(conversationId: conversationId)
    }
    
    func fetchRemoteMessages(conversationId: String, offsetTime: Date?) -> AnyPublisher<Message, Error> {
        messageRemoteDataSource.listenMessages(conversationId: conversationId, offsetTime: offsetTime)
    }
    
    func createMessage(message: Message) async throws {
        try await handleNetworkException(
            block: {
                try await messageLocalDataSource.upsertMessage(message: message)
                messagePublisher.send(message)
                try await messageRemoteDataSource.createMessage(message: message)
            },
            tag: tag,
            message: "Failed to create message"
        )
    }
        
    func updateSeenMessage(message: Message) async throws {
        try await handleNetworkException(
            block: {
                try await messageLocalDataSource.updateMessage(message: message)
                messagePublisher.send(message)
                try await messageRemoteDataSource.updateSeenMessage(message: message)
            }
        )
    }
    
    func upsertLocalMessage(message: Message) async throws {
        try await messageLocalDataSource.upsertMessage(message: message)
        messagePublisher.send(message)
    }
    
    func deleteLocalMessages(conversationId: String) async throws {
        try await messageLocalDataSource.deleteMessages(conversationId: conversationId)
    }
    
    func deleteLocalMessages() async throws {
        try await messageLocalDataSource.deleteMessages()
    }
    
    func stopListeningMessages() {
        messageRemoteDataSource.stopListeningMessages()
        cancellables.forEach { $0.cancel() }
    }
}
