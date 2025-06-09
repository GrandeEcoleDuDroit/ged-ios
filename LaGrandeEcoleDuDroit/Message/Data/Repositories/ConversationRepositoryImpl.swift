import Combine
import Foundation

private let tag = String(describing: ConversationRepositoryImpl.self)

class ConversationRepositoryImpl: ConversationRepository {
    private let messageRepository: MessageRepository
    private let userRepository: UserRepository
    private let conversationLocalDataSource: ConversationLocalDataSource
    private let conversationRemoteDataSource: ConversationRemoteDataSource
    private var interlocutors: [String: User] = [:]
    private let conversationChangesSubject = PassthroughSubject<CoreDataChange<Conversation>, Never>()
    var conversationChanges: AnyPublisher<CoreDataChange<Conversation>, Never> {
        conversationChangesSubject.eraseToAnyPublisher()
    }
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        messageRepository: MessageRepository,
        userRepository: UserRepository,
        conversationLocalDataSource: ConversationLocalDataSource,
        conversationRemoteDataSource: ConversationRemoteDataSource
    ) {
        self.messageRepository = messageRepository
        self.userRepository = userRepository
        self.conversationLocalDataSource = conversationLocalDataSource
        self.conversationRemoteDataSource = conversationRemoteDataSource
        listenDataChanges()
    }
    
    private func listenDataChanges() {
        conversationLocalDataSource.listenDataChange()
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] change in
                self?.conversationChangesSubject.send(change)
            }
            .store(in: &cancellables)
    }

    func getConversations() async -> [Conversation] {
        let conversations = try? await conversationLocalDataSource.getConversations()
        return conversations ?? []
    }
    
    func getConversation(interlocutorId: String) async -> Conversation? {
         try? await conversationLocalDataSource.getConversation(interlocutorId: interlocutorId)
    }
    
    func getLastConversationDate() async -> Date? {
        try? await conversationLocalDataSource.getLastConversation()?.createdAt
    }
    
    func fetchRemoteConversations(userId: String, offsetTime: Date?) -> AnyPublisher<Conversation, Error> {
        conversationRemoteDataSource
            .listenConversations(userId: userId, offsetTime: offsetTime)
            .flatMap { remoteConversation in
                guard let interlocutorId = remoteConversation.participants.first(where: { $0 != userId }) else {
                    return Empty<Conversation, Error>().eraseToAnyPublisher()
                }

                if let interlocutor = self.interlocutors[interlocutorId] {
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

    
    func createConversation(conversation: Conversation, userId: String) async throws {
        try await handleNetworkException(
            block: {
                try? await conversationLocalDataSource.insertConversation(conversation: conversation)
                try await conversationRemoteDataSource.createConversation(conversation: conversation, userId: userId)
            },
            tag: tag,
            message: "Failed to create conversation"
        )
    }
    
    func updateLocalConversation(conversation: Conversation) async {
        try? await conversationLocalDataSource.updateConversation(conversation: conversation)
    }
    
    func upsertLocalConversation(conversation: Conversation) async {
        try? await conversationLocalDataSource.upsertConversation(conversation: conversation)
    }
    
    func deleteConversation(conversation: Conversation, userId: String) async throws {
        let deleteTime = Date()
        try await handleNetworkException(
            block: {
                try? await conversationLocalDataSource.updateConversation(
                    conversation: conversation.with(deleteTime: deleteTime)
                )
                try await conversationRemoteDataSource.updateConversationDeleteTime(conversationId: conversation.id, userId: userId, deleteTime: deleteTime)
            }
        )
    }
    
    func deleteLocalConversations() async {
        try? await conversationLocalDataSource.deleteConversations()
    }
    
    func stopListenConversations() {
        conversationRemoteDataSource.stopListeningConversations()
    }
}
