import Foundation

class SendMessageUseCase {
    private let messageRepository: MessageRepository
    private let conversationRepository: ConversationRepository
    private let networkMonitor: NetworkMonitor
    private let sendMessageNotificationUseCase: SendMessageNotificationUseCase
    
    init(
        messageRepository: MessageRepository,
        conversationRepository: ConversationRepository,
        networkMonitor: NetworkMonitor,
        sendMessageNotificationUseCase: SendMessageNotificationUseCase
    ) {
        self.messageRepository = messageRepository
        self.conversationRepository = conversationRepository
        self.networkMonitor = networkMonitor
        self.sendMessageNotificationUseCase = sendMessageNotificationUseCase
    }
    
    func execute(conversation: Conversation, message: Message, userId: String) async {
        do {
            try await createDataLocally(conversation: conversation, message: message)
            try await createDataRemotely(conversation: conversation, message: message, userId: userId)
            let messageNotification = MessageNotification(
                conversation: conversation,
                message: MessageNotification.MessageContent(
                    content: message.content,
                    date: message.date.toEpochMilli()
                )
            )
            await sendMessageNotificationUseCase.execute(notification: messageNotification)
        } catch {
            if conversation.state == .draft {
                try? await conversationRepository.updateLocalConversation(conversation: conversation.copy { $0.state = .error })
            }
            try? await messageRepository.upsertLocalMessage(message: message.copy { $0.state = .error })
        }
    }
    
    private func createDataLocally(conversation: Conversation, message: Message) async throws {
        if conversation.state == .draft {
            try await conversationRepository.createLocalConversation(conversation: conversation.copy { $0.state = .creating })
        }
        
        if message.state == .draft {
            try await messageRepository.createLocalMessage(message: message.copy { $0.state = .sending })
        }
    }
    
    private func createDataRemotely(conversation: Conversation, message: Message, userId: String) async throws {
        if conversation.shouldBeCreated() {
            try await conversationRepository.createRemoteConversation(conversation: conversation,userId: userId)
        }
        try await messageRepository.createRemoteMessage(message: message)
    }
}
