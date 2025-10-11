import Combine
import Foundation

class ConversationRepositoryImpl: ConversationRepository {
    private let tag = String(describing: ConversationRepositoryImpl.self)
    private let conversationLocalDataSource: ConversationLocalDataSource
    private let conversationRemoteDataSource: ConversationRemoteDataSource
    private let userRepository: UserRepository
    
    private let fetchedInterlocutors: FetchedInterlocutors = FetchedInterlocutors()
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
                Future<FetchedInterlocutorResult, Never> { [weak self] promise in
                    guard let interlocutorId = remoteConversation.participants.first(where: { $0 != userId }) else {
                        return promise(.success(.failure))
                    }
                    
                    Task {
                        if let interlocutor = await self?.fetchedInterlocutors.get(interlocutorId: interlocutorId) {
                            let conversation = remoteConversation.toConversation(userId: userId, interlocutor: interlocutor)
                            promise(.success(.found(conversation)))
                        } else {
                            promise(.success(.notFound(remoteConversation, interlocutorId)))
                        }
                    }
                }.eraseToAnyPublisher()
            }
            .flatMap { result in
                switch result {
                    case let .found(conversation):
                        Just(conversation).eraseToAnyPublisher()
                        
                    case let .notFound(remoteConversation, interlocutorId):
                        self.userRepository.getUserPublisher(userId: interlocutorId)
                            .compactMap { $0 }
                            .map { interlocutor in
                                Task {
                                    await self.fetchedInterlocutors.set(interlocutor: interlocutor, forKey: interlocutorId)
                                }
                                return remoteConversation.toConversation(userId: userId, interlocutor: interlocutor)
                            }
                            .eraseToAnyPublisher()

                    default: Empty<Conversation, Never>().eraseToAnyPublisher()
                }
            }.eraseToAnyPublisher()
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
    
    func deleteConversation(conversation: Conversation, userId: String, deleteTime: Date) async throws {
        try await conversationRemoteDataSource.updateConversationDeleteTime(
            conversationId: conversation.id,
            userId: userId,
            deleteTime: deleteTime
        )
        if let deletedConversation = try await conversationLocalDataSource.deleteConversation(conversationId: conversation.id) {
            conversationChangesSubject.send(CoreDataChange(deleted: [deletedConversation]))
        }
    }
    
    func deleteLocalConversations() async throws {
        do {
            let deletedConversations = try await conversationLocalDataSource.deleteConversations()
            conversationChangesSubject.send(CoreDataChange(deleted: deletedConversations))
        } catch {
            e(tag, "Failed to delete local conversations \(error)", error)
            throw error
        }
    }
    
    func stopListenConversations() {
        conversationRemoteDataSource.stopListeningConversations()
        Task { await fetchedInterlocutors.removeAll() }
    }
}

private actor FetchedInterlocutors {
    private var interlocutors: [String: User] = [:]
    
    func get(interlocutorId: String) -> User? {
        interlocutors[interlocutorId]
    }
    
    func set(interlocutor: User, forKey key: String) {
        interlocutors[key] = interlocutor
    }
    
    func removeAll() {
        interlocutors.removeAll()
    }
}

private enum FetchedInterlocutorResult {
    case found(Conversation)
    case notFound(RemoteConversation, String)
    case failure
}
