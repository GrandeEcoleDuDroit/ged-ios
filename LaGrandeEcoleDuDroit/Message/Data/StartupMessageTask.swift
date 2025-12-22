class StartupMessageTask {
    private let networkMonitor: NetworkMonitor
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    private let tag = String(describing: StartupMessageTask.self)
    
    init(
        networkMonitor: NetworkMonitor,
        userRepository: UserRepository,
        conversationRepository: ConversationRepository,
        messageRepository: MessageRepository
    ) {
        self.networkMonitor = networkMonitor
        self.userRepository = userRepository
        self.conversationRepository = conversationRepository
        self.messageRepository = messageRepository
    }
    
    func run() {
        Task {
            await networkMonitor.connected.values.first { $0 }
            await sendUnsentConversations()
            await sendUnsentMessage()
        }
    }
    
    private func sendUnsentConversations() async {
        do {
            guard let userId = self.userRepository.currentUser?.id else { return }
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
    
    private func sendUnsentMessage() async {
        do {
            let messages = try await messageRepository.getUnsentMessages()
            for message in messages {
                try await messageRepository.createRemoteMessage(message: message)
                try await messageRepository.updateLocalMessage(message: message.copy { $0.state = .sent })
            }
        } catch {
            e(tag, "Failed to send unsent messages", error)
        }
    }
}
