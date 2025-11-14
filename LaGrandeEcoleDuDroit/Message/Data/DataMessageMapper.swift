import Firebase
import CoreData

extension RemoteMessage {
    func toMessage() -> Message {
        Message(
            id: messageId,
            senderId: senderId,
            recipientId: recipientId,
            conversationId: conversationId,
            content: content,
            date: timestamp.dateValue(),
            seen: seen,
            state: .sent
        )
    }
    
    func toMap() -> [String: Any] {
        [
            MessageField.Local.messageId: messageId,
            MessageField.Local.messageConversationId: conversationId,
            MessageField.Local.messageSenderId: senderId,
            MessageField.Local.messageRecipientId: recipientId,
            MessageField.Local.messageContent: content,
            MessageField.Local.messageTimestamp: timestamp,
            MessageField.Local.messageSeen: seen
        ]
    }
}

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
            content: content,
            date: date.toEpochMilli()
        )
    }
}

extension LocalMessage {
    func toMessage() -> Message? {
        guard let messageContent = messageContent,
              let messageTimestamp = messageTimestamp,
              let messageSenderId = messageSenderId,
              let messageRecipientId = messageRecipientId,
              let messageConversationId = messageConversationId,
              let messageState = MessageState(rawValue: messageState ?? "")
        else {
            return nil
        }
        
        return Message(
            id: messageId,
            senderId: messageSenderId,
            recipientId: messageRecipientId,
            conversationId: messageConversationId,
            content: messageContent,
            date: messageTimestamp,
            seen: messageSeen,
            state: messageState
        )
    }
}

extension MessageReport {
    func toRemote() -> RemoteMessageReport {
        RemoteMessageReport(
            conversationId: conversationId,
            messageId: messageId,
            recipientInfo: recipientInfo.toRemote(),
            reason: reason.rawValue
        )
    }
}

extension MessageReport.UserInfo {
    func toRemote() -> RemoteMessageReport.RemoteUserInfo {
        RemoteMessageReport.RemoteUserInfo(
            fullName: fullName,
            email: email
        )
    }
}
