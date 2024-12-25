import Foundation

struct ConversationUI: Identifiable, Hashable {
    var id: String
    var interlocutor: User
    var lastMessage: Message? = nil
    var createdAt: Date = Date.now
    var isCreated: Bool = false
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ConversationUI, rhs: ConversationUI) -> Bool {
        lhs.id == rhs.id &&
        lhs.interlocutor == rhs.interlocutor &&
        lhs.lastMessage == rhs.lastMessage &&
        lhs.createdAt == rhs.createdAt &&
        lhs.isCreated == rhs.isCreated
    }
    
    func with(
        id: String? = nil,
        interlocutor: User? = nil,
        lastMessage: Message? = nil,
        createdAt: Date? = nil,
        isCreated: Bool? = nil
    ) -> ConversationUI {
        ConversationUI(
            id: id ?? self.id,
            interlocutor: interlocutor ?? self.interlocutor,
            lastMessage: lastMessage ?? self.lastMessage,
            createdAt: createdAt ?? self.createdAt,
            isCreated: isCreated ?? self.isCreated
        )
    }
}
