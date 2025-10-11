import Combine
import Foundation

class MessageRepositoryImpl: MessageRepository {
    private let tag = String(describing: MessageRepositoryImpl.self)
    private let messageLocalDataSource: MessageLocalDataSource
    private let messageRemoteDataSource: MessageRemoteDataSource
    
    private var cancellables: Set<AnyCancellable> = []
    private let messageChangesSubject = PassthroughSubject<CoreDataChange<Message>, Never>()
    var messageChanges: AnyPublisher<CoreDataChange<Message>, Never> {
        messageChangesSubject.eraseToAnyPublisher()
    }
    
    init(
        messageLocalDataSource: MessageLocalDataSource,
        messageRemoteDataSource: MessageRemoteDataSource
    ) {
        self.messageLocalDataSource = messageLocalDataSource
        self.messageRemoteDataSource = messageRemoteDataSource
        listenDataChanges()
    }
    
    private func listenDataChanges() {
        messageLocalDataSource.listenDataChange()
            .sink { [weak self] change in
                self?.messageChangesSubject.send(change)
            }
            .store(in: &cancellables)
    }
 
    func getMessages(conversationId: String, offset: Int, limit: Int) async throws -> [Message] {
        do {
            return try await messageLocalDataSource.getMessages(
                conversationId: conversationId,
                offset: offset,
                limit: limit
            )
        } catch {
            e(tag, "Error to get local messages for conversation \(conversationId): \(error.localizedDescription)", error)
            throw error
        }
    }
    
    func getLastMessage(conversationId: String) async throws -> Message? {
        do {
            return try await messageLocalDataSource.getLastMessage(conversationId: conversationId)
        } catch {
            e(tag, "Error to get last local message for conversation \(conversationId): \(error.localizedDescription)", error)
            throw error
        }
    }
    
    func getUnsentMessages() async throws -> [Message] {
        do {
            return try await messageLocalDataSource.getUnsentMessages()
        } catch {
            e(tag, "Error to get unsent local messages: \(error.localizedDescription)", error)
            throw error
        }
    }
    
    func fetchRemoteMessages(conversation: Conversation, offsetTime: Date?) -> AnyPublisher<Message, Error> {
        messageRemoteDataSource.listenMessages(conversation: conversation, offsetTime: offsetTime)
    }
    
    func createLocalMessage(message: Message) async throws {
        do {
            try await messageLocalDataSource.insertMessage(message: message)
        } catch {
            e(tag, "Failed to create local message: \(error.localizedDescription)", error)
            throw error
        }
    }
    
    func createRemoteMessage(message: Message) async throws {
        try await messageRemoteDataSource.createMessage(message: message)
    }
    
    func updateLocalMessage(message: Message) async throws {
        do {
            try await messageLocalDataSource.updateMessage(message: message)
        } catch {
            e(tag, "Failed to update local message: \(error.localizedDescription)", error)
            throw error
        }
    }
        
    func updateSeenMessages(conversationId: String, currentUserId: String) async throws {
        let unreadMessages = (try? await messageLocalDataSource.getUnreadMessagesByUser(
            conversationId: conversationId,
            userId: currentUserId
        )) ?? []
        
        try await messageLocalDataSource.updateSeenMessages(conversationId: conversationId, userId: currentUserId)
        try await mapFirebaseException(
            block: {
                for message in unreadMessages {
                    try? await messageRemoteDataSource.updateSeenMessage(message: message.copy { $0.seen = true })
                }
            },
            tag: tag,
            message: "Failed to update seen messages"
        )
    }
    
    func updateSeenMessage(message: Message) async throws {
        try await messageLocalDataSource.updateMessage(message: message.copy { $0.seen = true })
        try await mapFirebaseException(
            block: { try? await messageRemoteDataSource.updateSeenMessage(message: message.copy { $0.seen = true })},
            tag: tag,
            message: "Failed to update seen messages"
        )
    }
    
    func upsertLocalMessage(message: Message) async throws {
        do {
            try await messageLocalDataSource.upsertMessage(message: message)
        } catch {
            e(tag, "Failed to upsert local message: \(error.localizedDescription)", error)
            throw error
        }
    }
    
    func deleteLocalMessage(message: Message) async throws {
        do {
            if let deletedMessage = try await messageLocalDataSource.deleteMessage(message: message) {
                messageChangesSubject.send(CoreDataChange(deleted: [deletedMessage]))
            }
        } catch {
            e(tag, "Failed to delete local message: \(error.localizedDescription)", error)
            throw error
        }
    }
    
    func deleteLocalMessages(conversationId: String) async throws {
        do {
            let deletedMessages = try await messageLocalDataSource.deleteMessages(conversationId: conversationId)
            messageChangesSubject.send(CoreDataChange(deleted: deletedMessages))
        } catch {
            e(tag, "Failed to delete local messages for conversation \(conversationId): \(error.localizedDescription)", error)
            throw error
        }
    }
    
    func deleteLocalMessages() async throws {
        do {
            let deletedMessages = try await messageLocalDataSource.deleteMessages()
            messageChangesSubject.send(CoreDataChange(deleted: deletedMessages))
        } catch {
            e(tag, "Failed to delete local messages: \(error.localizedDescription )", error)
            throw error
        }
    }
    
    func stopListeningMessages() {
        messageRemoteDataSource.stopListeningMessages()
    }
    
    func reportMessage(report: MessageReport) async throws {
        try await messageRemoteDataSource.reportMessage(report: report)
    }
}
