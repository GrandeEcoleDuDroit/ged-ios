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
    
    func buildLocal(context: NSManagedObjectContext) {
        let localMessage = LocalMessage(context: context)
        localMessage.messageId = Int32(id)
        localMessage.conversationId = conversationId
        localMessage.senderId = senderId
        localMessage.recipientId = recipientId
        localMessage.content = content
        localMessage.date = date
        localMessage.seen = seen
        localMessage.state = state.rawValue
    }
}

extension LocalMessage {
    func toMessage() -> Message? {
        guard let content = content,
              let date = date,
              let senderId = senderId,
              let recipientId = recipientId,
              let conversationId = conversationId,
              let state = MessageState(rawValue: state ?? "")
        else {
            return nil
        }
        
        return Message(
            id: messageId.toInt(),
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
