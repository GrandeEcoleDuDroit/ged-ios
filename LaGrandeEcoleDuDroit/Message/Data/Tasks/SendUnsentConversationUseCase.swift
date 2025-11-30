import Combine

class SendUnsentConversationUseCase {
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    private let userRepository: UserRepository
    
    private let tag = String(describing: SendUnsentConversationUseCase.self)
    
    init(
        conversationRepository: ConversationRepository,
        messageRepository: MessageRepository,
        userRepository: UserRepository
    ) {
        self.conversationRepository = conversationRepository
        self.messageRepository = messageRepository
        self.userRepository = userRepository
    }
    
    func execute() async {
        guard let userId = self.userRepository.currentUser?.id else { return }
        do {
            let conversations = try await self.conversationRepository.getLocalConversations()
            for conversation in conversations {
                switch conversation.state {
                    case .creating:
                        try await self.conversationRepository.createRemoteConversation(conversation: conversation, userId: userId)
                    
                    case .deleting:
                        if let deleteTime = conversation.deleteTime {
                            try await self.conversationRepository.deleteConversation(
                                conversation: conversation,
                                userId: userId,
                                deleteTime: deleteTime
                            )
                            try await self.messageRepository.deleteLocalMessages(conversationId: conversation.id)
                        }
                    
                    default: break
                }
            }
        } catch {
            e(tag, "Failed to send unsent conversations", error)
        }
    }
}
