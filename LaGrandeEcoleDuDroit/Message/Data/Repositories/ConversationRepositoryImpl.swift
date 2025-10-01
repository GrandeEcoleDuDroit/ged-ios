import Combine
import Foundation

class ConversationRepositoryImpl: ConversationRepository {
    private let tag = String(describing: ConversationRepositoryImpl.self)
    private let conversationLocalDataSource: ConversationLocalDataSource
    private let conversationRemoteDataSource: ConversationRemoteDataSource
    private let userRepository: UserRepository
    private var fetchedInterlocutors: [String: User] = [:]
    private var cancellables: Set<AnyCancellable> = []
    private let conversationChangesSubject = PassthroughSubject<CoreDataChange<Conversation>, Never>()
    var conversationChanges: AnyPublisher<CoreDataChange<Conversation>, Never> {
        conversationChangesSubject.eraseToAnyPublisher()
    }
    
    init(
        conversationLocalDataSource: ConversationLocalDataSource,
        conversationRemoteDataSource: ConversationRemoteDataSource,
        userRepository: UserRepository
    ) {
        self.conversationLocalDataSource = conversationLocalDataSource
        self.conversationRemoteDataSource = conversationRemoteDataSource
        self.userRepository = userRepository
        listenDataChanges()
    }
    
    private func listenDataChanges() {
        conversationLocalDataSource.listenDataChanges()
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] change in
                self?.conversationChangesSubject.send(change)
            }
            .store(in: &cancellables)
    }
    
    func getConversations() async throws -> [Conversation] {
        do {
            return try await conversationLocalDataSource.getConversations()
        } catch {
            e(tag, "Error get local conversations: \(error)", error)
            throw error
        }
    }
    
    func getConversation(interlocutorId: String) async throws -> Conversation? {
        do {
            return try await conversationLocalDataSource.getConversation(interlocutorId: interlocutorId)
        } catch {
            e(tag, "Error get local conversation with interlocutorId \(interlocutorId): \(error)", error)
            throw error
        }
    }
    
    func fetchRemoteConversation(userId: String) -> AnyPublisher<Conversation, Error> {
        conversationRemoteDataSource
            .listenConversations(userId: userId)
            .flatMap { remoteConversation in
                guard let interlocutorId = remoteConversation.participants.first(where: { $0 != userId }) else {
                    return Empty<Conversation, Error>().eraseToAnyPublisher()
                }

                if let interlocutor = self.fetchedInterlocutors[interlocutorId] {
                    let conversation = remoteConversation.toConversation(userId: userId, interlocutor: interlocutor)
                    
                    return Just(conversation)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    return self.userRepository.getUserPublisher(userId: interlocutorId)
                        .map { remoteConversation.toConversation(userId: userId, interlocutor: $0) }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    func createLocalConversation(conversation: Conversation) async throws {
        do {
            try await conversationLocalDataSource.insertConversation(conversation: conversation)
        } catch {
            e(tag, "Failed to create local conversation: \(error)", error)
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
            e(tag, "Failed to update local conversation: \(error)", error)
            throw error
        }
    }
    
    func updateConversationDeleteTime(conversation: Conversation, currentUserId: String) async throws {
        try await conversationRemoteDataSource.updateConversationDeleteTime(
            conversationId: conversation.id,
            userId: currentUserId,
            deleteTime: conversation.deleteTime!
        )
        try await conversationLocalDataSource.updateConversation(conversation: conversation)
    }
    
    func upsertLocalConversation(conversation: Conversation) async throws {
        do {
            try await conversationLocalDataSource.upsertConversation(conversation: conversation)
        } catch {
            e(tag, "Failed to upsert local conversation \(error)", error)
            throw error
        }
    }
    
    func deleteConversation(conversation: Conversation, userId: String) async throws {
        try await conversationRemoteDataSource.updateConversationDeleteTime(
            conversationId: conversation.id,
            userId: userId,
            deleteTime: conversation.deleteTime!
        )
        if let deletedConversation = try await conversationLocalDataSource.deleteConversation(conversationId: conversation.id) {
            conversationChangesSubject.send(.init(inserted: [], updated: [], deleted: [deletedConversation]))
        }
    }
    
    func deleteLocalConversations() async throws {
        do {
            let deletedConversations = try await conversationLocalDataSource.deleteConversations()
            conversationChangesSubject.send(.init(inserted: [], updated: [], deleted: deletedConversations))
        } catch {
            e(tag, "Failed to delete local conversations \(error)", error)
            throw error
        }
    }
    
    func stopListenConversations() {
        conversationRemoteDataSource.stopListeningConversations()
        fetchedInterlocutors.removeAll()
    }
}
