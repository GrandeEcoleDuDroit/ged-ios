import Foundation

struct ConversationUser: Hashable {
    var id: String
    var interlocutor: User
    var createdAt: Date = Date.now
    var isCreated: Bool = false
  
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ConversationUser, rhs: ConversationUser) -> Bool {
        lhs.id == rhs.id
    }
    
    func with(
        id: String? = nil,
        interlocutor: User? = nil,
        isCreated: Bool? = nil
    ) -> ConversationUser {
        ConversationUser(
            id: id ?? self.id,
            interlocutor: interlocutor ?? self.interlocutor,
            isCreated: isCreated ?? self.isCreated
        )
    }
}
