import Combine

private let tag = String(describing: MessageRepositoryImpl.self)

class MessageRepositoryImpl: MessageRepository {
    private let messageLocalDataSource: MessageLocalDataSource
    private let messageRemoteDataSource: MessageRemoteDataSource
    private var cancellables = Set<AnyCancellable>()

    init(
        messageLocalDataSource: MessageLocalDataSource,
        messageRemoteDataSource: MessageRemoteDataSource
    ) {
        self.messageLocalDataSource = messageLocalDataSource
        self.messageRemoteDataSource = messageRemoteDataSource
    }
    
    func getMessages(conversationId: String) -> AnyPublisher<Message, Error> {
        listenRemoteMessages(conversationId: conversationId)
        return messageLocalDataSource.messageSubject.eraseToAnyPublisher()
    }
    
    func getLastMessage(conversationId: String) -> AnyPublisher<Message?, ConversationError> {
        messageRemoteDataSource.listenLastMessage(conversationId: conversationId)
    }
    
    func createMessage(message: Message) async throws {
        try messageLocalDataSource.insertMessage(message: message)
        try await messageRemoteDataSource.createMessage(message: message)
    }
    
    func updateMessageState(messageId: String, messageState: MessageState) async throws {
        try await messageLocalDataSource.updateMessageState(messageId: messageId, state: messageState)
    }
    
    func stopGettingMessages() {
        messageRemoteDataSource.stopListeningMessages()
    }
    
    func stopGettingLastMessages() {
        messageRemoteDataSource.stopListeningLastMessages()
    }
    
    private func listenRemoteMessages(conversationId: String) {
        messageRemoteDataSource.listenMessages(conversationId: conversationId)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    e(tag, "Error listening remote messages: \(error)")
                }
            } receiveValue: { [weak self] message in
                do {
                    try self?.messageLocalDataSource.upsertMessage(message: message)
                } catch {
                    e(tag, "Error listening remote messages: \(error)")
                }
            }
            .store(in: &cancellables)
    }
}
