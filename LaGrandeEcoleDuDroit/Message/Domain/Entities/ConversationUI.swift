import Foundation

struct ConversationUI: Identifiable, Hashable {
    var id: String
    var interlocutor: User
    var lastMessage: Message? = nil
    var createdAt: Date = Date.now
    var state: ConversationState
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func with(
        id: String? = nil,
        interlocutor: User? = nil,
        lastMessage: Message? = nil,
        createdAt: Date? = nil,
        state: ConversationState? = nil
    ) -> ConversationUI {
        ConversationUI(
            id: id ?? self.id,
            interlocutor: interlocutor ?? self.interlocutor,
            lastMessage: lastMessage ?? self.lastMessage,
            createdAt: createdAt ?? self.createdAt,
            state: state ?? self.state
        )
    }
}
