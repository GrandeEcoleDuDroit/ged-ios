import Foundation

struct ConversationUI: Identifiable, Hashable {
    var id: String
    var interlocutor: User
    var lastMessage: Message? = nil
    var createdAt: Date = Date.now
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ConversationUI, rhs: ConversationUI) -> Bool {
        return lhs.id == rhs.id &&
        lhs.interlocutor == rhs.interlocutor &&
        lhs.lastMessage == rhs.lastMessage &&
        lhs.createdAt == rhs.createdAt
    }
    
    
    func with(
        id: String? = nil,
        interlocutor: User? = nil,
        lastMessage: Message? = nil,
        createdAt: Date? = nil
    ) -> ConversationUI {
        ConversationUI(
            id: id ?? self.id,
            interlocutor: interlocutor ?? self.interlocutor,
            lastMessage: lastMessage ?? self.lastMessage,
            createdAt: createdAt ?? self.createdAt
        )
    }
}
