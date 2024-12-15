import Foundation

struct ConversationUser: Hashable {
    var id: String
    var interlocutor: User
    var createdAt: Date = Date.now
  
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ConversationUser, rhs: ConversationUser) -> Bool {
        lhs.id == rhs.id
    }
    
    func with(
        id: String? = nil,
        interlocutor: User? = nil
    ) -> ConversationUser {
        ConversationUser(
            id: id ?? self.id,
            interlocutor: interlocutor ?? self.interlocutor
        )
    }
}
