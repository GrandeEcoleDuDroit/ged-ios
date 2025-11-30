import Combine
import Foundation

private let tag = String(describing: ConversationRepositoryImpl.self)

class ConversationRepositoryImpl: ConversationRepository {
    private let conversationLocalDataSource: ConversationLocalDataSource
    private let conversationRemoteDataSource: ConversationRemoteDataSource
    private let userRepository: UserRepository
    
    private let fetchedInterlocutorsActor: InterlocutorActor = InterlocutorActor()
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
    
    func getLocalConversations() async throws -> [Conversation] {
        do {
            return try await conversationLocalDataSource.getConversations()
        } catch {
            e(tag, "Error get local conversations", error)
            throw error
        }
    }
    
    func getLocalConversation(interlocutorId: String) async throws -> Conversation? {
        do {
            return try await conversationLocalDataSource.getConversation(interlocutorId: interlocutorId)
        } catch {
            e(tag, "Error get local conversation with interlocutor: \(interlocutorId)", error)
            throw error
        }
    }
    
    func fetchRemoteConversations(userId: String) -> AnyPublisher<Conversation, Error> {
        conversationRemoteDataSource
            .listenConversations(userId: userId)
            .flatMap { remoteConversation in
                Future<FetchedInterlocutorResult, Never> { [weak self] promise in
                    guard let interlocutorId = remoteConversation.participants.first(where: { $0 != userId }) else {
                        return promise(.success(.empty))
                    }
                    
                    Task {
                        if let interlocutor = await self?.fetchedInterlocutorsActor.getInterlocutor(interlocutorId: interlocutorId) {
                            let conversation = remoteConversation.toConversation(userId: userId, interlocutor: interlocutor)
                            promise(.success(.fetched(conversation)))
                        } else {
                            promise(.success(.toFetch(remoteConversation, interlocutorId)))
                        }
                    }
                }.eraseToAnyPublisher()
            }
            .flatMap { result in
                switch result {
                    case let .fetched(conversation): Just(conversation).eraseToAnyPublisher()
                        
                    case let .toFetch(remoteConversation, interlocutorId):
                        self.userRepository.getUserPublisher(userId: interlocutorId)
                            .catch{ error in
                                e(tag, "Failed to listen interlocutor", error)
                                return Empty<User?, Never>()
                            }
                            .compactMap { $0 }
                            .map { interlocutor in
                                Task {
                                    await self.fetchedInterlocutorsActor.setInterlocutor(
                                        interlocutor: interlocutor,
                                        forKey: interlocutorId
                                    )
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
            e(tag, "Failed to upsert local conversation", error)
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
            e(tag, "Failed to delete local conversations", error)
            throw error
        }
    }
    
    func stopListenConversations() {
        conversationRemoteDataSource.stopListeningConversations()
        Task { await fetchedInterlocutorsActor.removeAllInterlocutors() }
    }
    
    private func listenDataChanges() {
        conversationLocalDataSource.listenDataChanges()
            .sink { [weak self] change in
                self?.conversationChangesSubject.send(change)
            }
            .store(in: &cancellables)
    }
}

private actor InterlocutorActor {
    private var interlocutors: [String: User] = [:]
    
    func getInterlocutor(interlocutorId: String) -> User? {
        interlocutors[interlocutorId]
    }
    
    func setInterlocutor(interlocutor: User, forKey key: String) {
        interlocutors[key] = interlocutor
    }
    
    func removeAllInterlocutors() {
        interlocutors.removeAll()
    }
}

private enum FetchedInterlocutorResult {
    case fetched(Conversation)
    case toFetch(RemoteConversation, String)
    case empty
}
