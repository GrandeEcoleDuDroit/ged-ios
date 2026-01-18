import Foundation

class SendMessageUseCase {
    private let messageRepository: MessageRepository
    private let conversationRepository: ConversationRepository
    private let sendMessageNotificationUseCase: SendMessageNotificationUseCase
    
    init(
        messageRepository: MessageRepository,
        conversationRepository: ConversationRepository,
        sendMessageNotificationUseCase: SendMessageNotificationUseCase
    ) {
        self.messageRepository = messageRepository
        self.conversationRepository = conversationRepository
        self.sendMessageNotificationUseCase = sendMessageNotificationUseCase
    }
    
    func execute(conversation: Conversation, message: Message, userId: String) async {
        do {
            try await createDataLocally(conversation: conversation, message: message)
            try await createDataRemotely(conversation: conversation, message: message, userId: userId)
            await sendNotification(conversation: conversation, message: message)
        } catch {
            if conversation.state == .draft {
                try? await conversationRepository.upsertLocalConversation(conversation: conversation.copy { $0.state = .error })
            }
            try? await messageRepository.upsertLocalMessage(message: message.copy { $0.state = .error })
        }
    }
    
    private func createDataLocally(conversation: Conversation, message: Message) async throws {
        if conversation.state == .draft {
            try? await conversationRepository.createLocalConversation(conversation: conversation.copy { $0.state = .creating })
        }
        
        if message.state == .draft {
            try await messageRepository.createLocalMessage(message: message.copy { $0.state = .sending })
        } else if message.state == .error {
            try await messageRepository.updateLocalMessage(message: message.copy { $0.state = .sending })
        }
    }
    
    private func createDataRemotely(conversation: Conversation, message: Message, userId: String) async throws {
        if conversation.state == .draft {
            try await conversationRepository.createRemoteConversation(conversation: conversation,userId: userId)
            try? await conversationRepository.updateLocalConversation(conversation: conversation.copy { $0.state = .created })
        }
        try await messageRepository.createRemoteMessage(message: message)
        try await messageRepository.updateLocalMessage(message: message.copy { $0.state = .sent })
    }
    
    private func sendNotification(conversation: Conversation, message: Message) async {
        let messageNotification = MessageNotification(
            conversation: conversation,
            message: MessageNotification.MessageContent(
                messageId: message.id,
                content: message.content,
                timestamp: message.date.toEpochMilli()
            )
        )
        await sendMessageNotificationUseCase.execute(notification: messageNotification)
    }
}
