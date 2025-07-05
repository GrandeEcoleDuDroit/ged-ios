import Combine

class SynchronizeMessageTask {
    private let messageRepository: MessageRepository
    private let tag = String(describing: SynchronizeConversationTask.self)
    
    init(messageRepository: MessageRepository) {
        self.messageRepository = messageRepository
    }
    
    func start() async {
        do {
            let messages = try await self.messageRepository.getUnsentMessages()
            
            for message in messages {
                try await self.messageRepository.createRemoteMessage(message: message)
            }
        } catch {
            e(self.tag, "Failed to synchronize messages: \(error.localizedDescription)", error)
        }
    }
}
