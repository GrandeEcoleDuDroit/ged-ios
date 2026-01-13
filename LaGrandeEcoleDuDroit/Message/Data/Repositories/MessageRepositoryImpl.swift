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
            e(tag, "Error geting local messages for conversation \(conversationId)", error)
            throw error
        }
    }
    
    func getLastMessage(conversationId: String) async throws -> Message? {
        do {
            return try await messageLocalDataSource.getLastMessage(conversationId: conversationId)
        } catch {
            e(tag, "Error getting last local message for conversation \(conversationId)", error)
            throw error
        }
    }
    
    func getUnsentMessages() async throws -> [Message] {
        do {
            return try await messageLocalDataSource.getUnsentMessages()
        } catch {
            e(tag, "Error getting unsent local messages", error)
            throw error
        }
    }
    
    func fetchRemoteMessages(userId: String, conversation: Conversation, offsetTime: Date?) -> AnyPublisher<Message, Error> {
        messageRemoteDataSource.listenMessages(userId: userId, conversation: conversation, offsetTime: offsetTime)
    }
    
    func createLocalMessage(message: Message) async throws {
        do {
            try await messageLocalDataSource.insertMessage(message: message)
        } catch {
            e(tag, "Error creating local message", error)
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
            e(tag, "Error updating local message", error)
            throw error
        }
    }
        
    func setMessagesSeen(conversationId: String, currentUserId: String) async throws {
        do {
            let unseenMessages = try? await messageLocalDataSource.getUserUnseenMessages(
                conversationId: conversationId,
                userId: currentUserId
            )
            
            try await messageLocalDataSource.setMessagesSeen(conversationId: conversationId, currentUserId: currentUserId)
            for message in unseenMessages ?? [] {
                try? await messageRemoteDataSource.setMessagesSeen(message: message)
            }
        } catch {
            e(tag, "Error setting messages as seen for conversation \(conversationId)")
            throw mapFirebaseError(error)
        }
    }
    
    func setMessageSeen(message: Message) async throws {
        do {
            try? await messageRemoteDataSource.setMessagesSeen(message: message)
            try await messageLocalDataSource.setMessageSeen(messageId: message.id)
        } catch {
            e(tag, "Error setting message as seen for conversation \(message.conversationId)")
            throw mapFirebaseError(error)
        }
    }
    
    func updateMessageVisibility(message: Message, currentUserId: String, visible: Bool) async throws {
        do {
            try await messageRemoteDataSource.updateMessageVisibility(message: message, userId: currentUserId, visible: visible)
        } catch {
            e(tag, "Error updating message \(message.id) visibility to \(visible) for conversation \(message.conversationId)", error)
            throw error
        }
    }
    
    func upsertLocalMessage(message: Message) async throws {
        do {
            try await messageLocalDataSource.upsertMessage(message: message)
        } catch {
            e(tag, "Error upserting local message", error)
            throw error
        }
    }
    
    func deleteLocalMessage(message: Message) async throws {
        do {
            if let deletedMessage = try await messageLocalDataSource.deleteMessage(message: message) {
                messageChangesSubject.send(CoreDataChange(deleted: [deletedMessage]))
            }
        } catch {
            e(tag, "Error deleting local message", error)
            throw error
        }
    }
    
    func deleteLocalMessages(conversationId: String) async throws {
        do {
            let deletedMessages = try await messageLocalDataSource.deleteMessages(conversationId: conversationId)
            messageChangesSubject.send(CoreDataChange(deleted: deletedMessages))
        } catch {
            e(tag, "Error deleting local messages for conversation \(conversationId)", error)
            throw error
        }
    }
    
    func deleteLocalMessages() async throws {
        do {
            let deletedMessages = try await messageLocalDataSource.deleteMessages()
            messageChangesSubject.send(CoreDataChange(deleted: deletedMessages))
        } catch {
            e(tag, "Error deleting local messages", error)
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
