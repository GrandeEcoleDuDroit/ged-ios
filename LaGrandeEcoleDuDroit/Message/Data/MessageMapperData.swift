import Firebase
import CoreData

extension Message {
    func toRemote() -> RemoteMessage {
        RemoteMessage(
            messageId: id,
            conversationId: conversationId,
            senderId: senderId,
            recipientId: recipientId,
            content: content,
            timestamp: Timestamp(date: date),
            seen: seen
        )
    }
    
    func toMessageContent() -> MessageNotification.MessageContent {
        MessageNotification.MessageContent(
            messageId: id,
            content: content,
            timestamp: date.toEpochMilli()
        )
    }
    
    func buildLocal(localMessage: LocalMessage) {
        localMessage.messageId = id
        localMessage.messageConversationId = conversationId
        localMessage.messageSenderId = senderId
        localMessage.messageRecipientId = recipientId
        localMessage.messageContent = content
        localMessage.messageDate = date
        localMessage.messageSeen = seen
        localMessage.messageState = state.rawValue
    }
    
    func toMessageNotificationContent() -> MessageNotification.MessageContent {
        MessageNotification.MessageContent(
            messageId: id,
            content: content,
            timestamp: date.toEpochMilli()
        )
    }
}

extension LocalMessage {
    func toMessage() -> Message? {
        guard let id = messageId,
              let senderId = messageSenderId,
              let recipientId = messageRecipientId,
              let conversationId = messageConversationId,
              let content = messageContent,
              let date = messageDate,
              let messageState = messageState,
              let state = MessageState(rawValue: messageState)
        else { return nil }
        
        return Message(
            id: id,
            senderId: senderId,
            recipientId: recipientId,
            conversationId: conversationId,
            content: content,
            date: date,
            seen: messageSeen,
            state: state
        )
    }
    
    func modify(message: Message) {
        messageState = message.state.rawValue
        messageSeen = message.seen
    }
    
    func equals(_ message: Message) -> Bool {
        messageId == message.id &&
        messageSenderId == message.senderId &&
        messageRecipientId == message.recipientId &&
        messageConversationId == message.conversationId &&
        messageContent == message.content &&
        messageDate == message.date &&
        messageSeen == message.seen &&
        messageState == message.state.rawValue
    }
}

extension RemoteMessage {
    func toMessage(userId: String) -> Message {
        Message(
            id: messageId,
            senderId: senderId,
            recipientId: recipientId,
            conversationId: conversationId,
            content: content,
            date: timestamp.dateValue(),
            seen: seen,
            state: .sent,
            visible: !(notVisibleFor?[userId] ?? false)
        )
    }
    
    func toMap() -> [String: Any] {
        [
            MessageField.Remote.messageId: messageId,
            MessageField.Remote.conversationId: conversationId,
            MessageField.Remote.senderId: senderId,
            MessageField.Remote.recipientId: recipientId,
            MessageField.Remote.content: content,
            MessageField.Remote.timestamp: timestamp,
            MessageField.Remote.seen: seen
        ]
    }
}

extension MessageReport {
    func toRemote() -> RemoteMessageReport {
        RemoteMessageReport(
            conversationId: conversationId,
            messageId: messageId,
            recipient: recipient.toRemote(),
            reason: reason.rawValue
        )
    }
}

extension MessageReport.Recipient {
    func toRemote() -> RemoteMessageReport.RemoteRecipient {
        RemoteMessageReport.RemoteRecipient(
            fullName: fullName,
            email: email
        )
    }
}
