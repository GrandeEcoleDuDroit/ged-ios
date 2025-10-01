import Combine

class SendUnsentMessageUseCase {
    private let messageRepository: MessageRepository
    private let tag = String(describing: SendUnsentMessageUseCase.self)
    
    init(messageRepository: MessageRepository) {
        self.messageRepository = messageRepository
    }
    
    func execute() async {
        do {
            let messages = try await messageRepository.getUnsentMessages()
            for message in messages {
                try await messageRepository.createRemoteMessage(message: message)
                try await messageRepository.updateLocalMessage(message: message.copy { $0.state = .sent })
            }
        } catch {
            e(tag, "Failed to send unsent messages: \(error.localizedDescription)", error)
        }
    }
}
