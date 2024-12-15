import Combine

class GetLastMessagesUseCase {
    private let messageRepository: MessageRepository
    
    init(messageRepository: MessageRepository) {
        self.messageRepository = messageRepository
    }
    
    func execute(conversationId: String) -> AnyPublisher<Message?, Error> {
        messageRepository.getLastMessage(conversationId: conversationId)
    }
    
    func stop() {
        messageRepository.stopGettingLastMessages()
    }
}
