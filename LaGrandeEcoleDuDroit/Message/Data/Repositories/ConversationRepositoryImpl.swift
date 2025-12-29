import Combine
import Foundation

private let tag = String(describing: ConversationRepositoryImpl.self)

class ConversationRepositoryImpl: ConversationRepository {
    private let conversationLocalDataSource: ConversationLocalDataSource
    private let conversationRemoteDataSource: ConversationRemoteDataSource

    private var cancellables: Set<AnyCancellable> = []
    private let conversationChangesSubject = PassthroughSubject<CoreDataChange<Conversation>, Never>()
    var conversationChanges: AnyPublisher<CoreDataChange<Conversation>, Never> {
        conversationChangesSubject.eraseToAnyPublisher()
    }
    
    init(
        conversationLocalDataSource: ConversationLocalDataSource,
        conversationRemoteDataSource: ConversationRemoteDataSource
    ) {
        self.conversationLocalDataSource = conversationLocalDataSource
        self.conversationRemoteDataSource = conversationRemoteDataSource
        listenLocalConversationChanges()
    }
    
    func getLocalConversations() async -> [Conversation] {
        do {
            return try await conversationLocalDataSource.getConversations()
        } catch {
            e(tag, "Failed to get local conversations: \(error.localizedDescription)")
            return []
        }
    }
    
    func getLocalConversation(interlocutorId: String) async -> Conversation? {
        do {
            return try await conversationLocalDataSource.getConversation(interlocutorId: interlocutorId)
        } catch {
            e(tag, "Failed to get local conversation with interlocutor: \(interlocutorId):: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getRemoteConversationsPublisher(user: User) -> AnyPublisher<RemoteConversation, Never> {
        conversationRemoteDataSource.listenConversations(userId: user.id)
            .catch { error in
                e(tag, "Failed to fetch remote conversations: \(error.localizedDescription)")
                return Empty<RemoteConversation, Never>()
            }
            .eraseToAnyPublisher()
    }
    
    func createLocalConversation(conversation: Conversation) async throws {
        do {
            try await conversationLocalDataSource.insertConversation(conversation: conversation)
        } catch {
            e(tag, "Failed to create local conversation", error)
            throw error
        }
    }
    
    func createRemoteConversation(conversation: Conversation, userId: String) async throws {
        try await conversationRemoteDataSource.createConversation(conversation: conversation, userId: userId)
    }
    
    func updateLocalConversation(conversation: Conversation) async throws {
        do {
            try await conversationLocalDataSource.updateConversation(conversation: conversation)
        } catch {
            e(tag, "Failed to update local conversation", error)
            throw error
        }
    }
    
    func updateConversationEffectiveFrom(conversationId: String, currentUserId: String, effectiveFrom: Date) async throws {
        try await conversationRemoteDataSource.updateConversationEffectiveFrom(
            conversationId: conversationId,
            userId: currentUserId,
            date: effectiveFrom
        )
        try await conversationLocalDataSource.updateConversationEffectiveFrom(
            conversationId: conversationId,
            effectiveFrom: effectiveFrom
        )
    }
    
    func upsertLocalConversation(conversation: Conversation) async throws {
        do {
            try await conversationLocalDataSource.upsertConversation(conversation: conversation)
        } catch {
            e(tag, "Failed to upsert local conversation", error)
            throw error
        }
    }
    
    func deleteConversation(conversationId: String, userId: String, date: Date) async throws {
        try await conversationRemoteDataSource.updateConversationEffectiveFrom(conversationId: conversationId, userId: userId, date: date)
        if let deletedConversation = try await conversationLocalDataSource.deleteConversation(conversationId: conversationId) {
            conversationChangesSubject.send(CoreDataChange(deleted: [deletedConversation]))
        }
    }
    
    func deleteLocalConversations() async throws {
        do {
            let deletedConversations = try await conversationLocalDataSource.deleteConversations()
            conversationChangesSubject.send(CoreDataChange(deleted: deletedConversations))
        } catch {
            e(tag, "Failed to delete local conversations", error)
            throw error
        }
    }
    
    func stopListenConversations() {
        conversationRemoteDataSource.stopListeningConversations()
    }
    
    private func listenLocalConversationChanges() {
        conversationLocalDataSource.listenDataChanges()
            .sink { [weak self] change in
                self?.conversationChangesSubject.send(change)
            }
            .store(in: &cancellables)
    }
}
