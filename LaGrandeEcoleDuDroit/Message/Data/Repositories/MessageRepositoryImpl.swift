import Combine
import Foundation


class MessageRepositoryImpl: MessageRepository {
    private let messageLocalDataSource: MessageLocalDataSource
    private let messageRemoteDataSource: MessageRemoteDataSource
    private let messageChangesSubject = PassthroughSubject<CoreDataChange<Message>, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let tag = String(describing: MessageRepositoryImpl.self)
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
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] change in
                self?.messageChangesSubject.send(change)
            }
            .store(in: &cancellables)
    }

    func getMessages(conversationId: String, offset: Int) async -> [Message] {
        (try? await messageLocalDataSource.getMessages(conversationId: conversationId, offset: offset)) ?? []
    }
    
    func getLastMessage(conversationId: String) async -> Message? {
        try? await messageLocalDataSource.getLastMessage(conversationId: conversationId)
    }
    
    func fetchRemoteMessages(conversation: Conversation, offsetTime: Date?) -> AnyPublisher<Message, Error> {
        messageRemoteDataSource.listenMessages(conversation: conversation, offsetTime: offsetTime)
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
    
    deinit {
        stopListeningMessages()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
