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
            MessageField.messageId: messageId,
            MessageField.conversationId: conversationId,
            MessageField.senderId: senderId,
            MessageField.recipientId: recipientId,
            MessageField.content: content,
            MessageField.timestamp: timestamp,
            MessageField.seen: seen
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
}

extension LocalMessage {
    func toMessage() -> Message? {
        guard let content = content,
              let date = timestamp,
              let senderId = senderId,
              let recipientId = recipientId,
              let conversationId = conversationId,
              let state = MessageState(rawValue: state ?? "")
        else {
            return nil
        }
        
        return Message(
            id: messageId,
            senderId: senderId,
            recipientId: recipientId,
            conversationId: conversationId,
            content: content,
            date: date,
            seen: seen,
            state: state
        )
    }
}
