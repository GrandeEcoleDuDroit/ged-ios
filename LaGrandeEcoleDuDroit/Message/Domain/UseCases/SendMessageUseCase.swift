class SendMessageUseCase {
    private let messageRepository: MessageRepository

    init(messageRepository: MessageRepository) {
        self.messageRepository = messageRepository
    }
    
    func execute(message: Message) async throws {
        do {
            try await messageRepository.createMessage(message: message)
            try await messageRepository.updateMessageState(messageId: message.id, messageState: .sent)
        } catch {
            try await messageRepository.updateMessageState(messageId: message.id, messageState: .error)
            throw error
        }
    }
}
