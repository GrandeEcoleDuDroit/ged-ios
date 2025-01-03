import Firebase
import CoreData

class MessageMapper {
    static func toDomain(remoteMessage: RemoteMessage) -> Message? {
        guard let type = MessageType(rawValue: remoteMessage.type) else {
            return nil
        }
        
        return Message(
            id: remoteMessage.messageId,
            conversationId: remoteMessage.conversationId,
            content: remoteMessage.content,
            date: remoteMessage.timestamp.dateValue(),
            isRead: remoteMessage.isRead,
            senderId: remoteMessage.senderId,
            type: type,
            state: .sent
        )
    }
    
    static func toDomain(localMessage: LocalMessage) -> Message? {
        guard let id = localMessage.messageId,
              let conversationId = localMessage.conversationId,
              let content = localMessage.content,
              let date = localMessage.date,
              let senderId = localMessage.senderId,
              let type = MessageType(rawValue: localMessage.type ?? ""),
              let state = MessageState(rawValue: localMessage.state ?? "")
        else {
            return nil
        }
        
        return Message(
            id: id,
            conversationId: conversationId,
            content: content,
            date: date,
            isRead: localMessage.isRead,
            senderId: senderId,
            type: type,
            state: state
        )
    }

    static func toLocal(message: Message, context: NSManagedObjectContext) {
        let localMessage = LocalMessage(context: context)
        localMessage.messageId = message.id
        localMessage.conversationId = message.conversationId
        localMessage.senderId = message.senderId
        localMessage.content = message.content
        localMessage.date = message.date
        localMessage.isRead = message.isRead
        localMessage.type = message.type.rawValue
        localMessage.state = message.state.rawValue
    }
    
    static func toRemote(message: Message) -> RemoteMessage {
        RemoteMessage(
            messageId: message.id,
            conversationId: message.conversationId,
            senderId: message.senderId,
            content: message.content,
            timestamp: Timestamp(date: message.date),
            isRead: message.isRead,
            type: message.type.rawValue
        )
    }
}
