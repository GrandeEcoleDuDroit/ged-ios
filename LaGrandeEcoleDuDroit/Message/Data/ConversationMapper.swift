import Foundation

class ConversationMapper {
    static func toDomain(localConversation: LocalConversation) -> Conversation? {
        do {
            let interlocutor = try JSONDecoder().decode(User.self, from: localConversation.interlocutorJson!.data(using: .utf8)!)
            return Conversation(
                id: localConversation.conversationId!,
                interlocutor: interlocutor,
                message: messageFixture,
                isActive: localConversation.isActive
            )
        } catch {
            return nil
        }
        
    }
}
