import Foundation

struct ConversationUser: Hashable {
    var id: String
    var interlocutor: User
    var createdAt: Date = Date.now
    var state: ConversationState
  
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
  
    func with(
        id: String? = nil,
        interlocutor: User? = nil,
        state: ConversationState? = nil
    ) -> ConversationUser {
        ConversationUser(
            id: id ?? self.id,
            interlocutor: interlocutor ?? self.interlocutor,
            state: state ?? self.state
        )
    }
}
