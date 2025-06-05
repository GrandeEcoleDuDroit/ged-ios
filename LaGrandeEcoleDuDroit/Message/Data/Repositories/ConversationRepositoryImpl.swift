import Combine
import Foundation

private let tag = String(describing: ConversationRepositoryImpl.self)

class ConversationRepositoryImpl: ConversationRepository {
    private let messageRepository: MessageRepository
    private let userRepository: UserRepository
    private let conversationLocalDataSource: ConversationLocalDataSource
    private let conversationRemoteDataSource: ConversationRemoteDataSource
    private var interlocutors: [String: User] = [:]
    private let conversationsPublisher = CurrentValueSubject<[String: Conversation], Never>([:])
    
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
        initConversations()
    }
    
    private func initConversations() {
        Task {
            do {
                try await conversationLocalDataSource.getConversations().forEach { conversation in
                    conversationsPublisher.value[conversation.id] = conversation
                }
            } catch {
                e(tag, "Failed to load conversations: \(error)", error)
            }
        }
    }
    
    var conversations: AnyPublisher<[Conversation], Never> {
        conversationsPublisher
            .map { $0.values.map(\.self) }
            .eraseToAnyPublisher()
    }
    
    func getConversation(interlocutorId: String) async -> Conversation? {
         try? await conversationLocalDataSource.getConversation(interlocutorId: interlocutorId)
    }
    
    func fetchRemoteConversations(userId: String) -> AnyPublisher<Conversation, Error> {
        conversationRemoteDataSource
            .listenConversations(userId: userId)
            .flatMap { remoteConversation in
                guard let interlocutorId = remoteConversation
                    .participants
                    .first(where: { $0 != userId })
                else {
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
                try await conversationLocalDataSource.upsertConversation(conversation: conversation)
                try await conversationRemoteDataSource.createConversation(conversation: conversation, userId: userId)
                conversationsPublisher.value[conversation.id] = conversation
            },
            tag: tag,
            message: "Failed to create conversation"
        )
    }
    
    func updateLocalConversation(conversation: Conversation) async throws {
        try await conversationLocalDataSource.updateConversation(conversation: conversation)
        conversationsPublisher.value[conversation.id] = conversation
    }
    
    func upsertLocalConversation(conversation: Conversation) async throws {
        try await conversationLocalDataSource.upsertConversation(conversation: conversation)
        conversationsPublisher.value[conversation.id] = conversation
    }
    
    func deleteConversation(conversationId: String, userId: String) async throws {
        let deleteTime = Date()
        try await handleNetworkException(
            block: {
                try await conversationRemoteDataSource.updateConversationDeleteTime(conversationId: conversationId, userId: userId, deleteTime: deleteTime)
                try await conversationLocalDataSource.deleteConversation(conversationId: conversationId)
                conversationsPublisher.value.removeValue(forKey: conversationId)
            }
        )
    }
    
    func deleteLocalConversations() async throws {
        try await conversationLocalDataSource.deleteConversations()
        conversationsPublisher.value.removeAll()
    }
    
    func stopListenConversations() {
        conversationRemoteDataSource.stopListeningConversations()
    }
}
