import Foundation
import CoreData

class ConversationMapper {
    static func toConversationWithInterlocutor(localConversation: LocalConversation) -> (Conversation, User)? {
        guard let interlocutorJson = localConversation.interlocutorJson,
              let data = interlocutorJson.data(using: .utf8),
              let conversationId = localConversation.conversationId,
              let createdAt = localConversation.createdAt else {
            return nil
        }

        guard let interlocutor = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        
        let conversation = Conversation(
            id: conversationId,
            interlocutorId: interlocutor.id,
            createdAt: createdAt
        )
        
        return (conversation, interlocutor)
    }

    
    static func toConversationUser(conversation: Conversation, interlocutor: User) -> ConversationUser {
        ConversationUser(
            id: conversation.id,
            interlocutor: interlocutor,
            createdAt: conversation.createdAt
        )
    }
    
    static func toConversation(remoteConversation: RemoteConversation, currrentUserId: String) -> Conversation? {
        guard let interlocutorId = remoteConversation.participants.first(where: { $0 != currrentUserId }) else {
            return nil
        }
        
        return Conversation(
            id: remoteConversation.conversationId,
            interlocutorId: interlocutorId,
            createdAt: remoteConversation.createdAt.dateValue()
        )
    }
    
    static func toLocal(conversation: Conversation, interlocutor: User, context: NSManagedObjectContext) throws -> LocalConversation {
        guard let interlocutorJson = try? JSONEncoder().encode(interlocutor),
              let interlocutorJsonString = String(data: interlocutorJson, encoding: .utf8) else {
            throw NSError(domain: "Error to encode interlocutor", code: 0, userInfo: nil)
        }
        
        let localConversation = LocalConversation(context: context)
        localConversation.conversationId = conversation.id
        localConversation.interlocutorJson = interlocutorJsonString
        localConversation.createdAt = conversation.createdAt
        return localConversation
    }
    
    static func toLocal(conversation: Conversation, interlocutor: User) -> LocalConversation? {
        guard let interlocutorJson = try? String(data: JSONEncoder().encode(interlocutor), encoding: .utf8) else {
            return nil
        }
        
        let localConversation = LocalConversation()
        localConversation.conversationId = conversation.id
        localConversation.interlocutorJson = interlocutorJson
        localConversation.createdAt = conversation.createdAt
        
        return localConversation
    }
}
