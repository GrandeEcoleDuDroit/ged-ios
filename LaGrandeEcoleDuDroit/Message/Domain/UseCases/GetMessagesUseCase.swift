import Combine

class GetMessagesUseCase {
    private let messageRepository: MessageRepository
    
    init(messageRepository: MessageRepository) {
        self.messageRepository = messageRepository
    }
    
    func execute(conversationId: String) -> AnyPublisher<[Message], Error> {
        messageRepository.getMessages(conversationId: conversationId)
    }
    
    func stop() {
        messageRepository.stopGettingMessages()
    }
}
