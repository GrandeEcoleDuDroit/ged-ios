import Foundation

struct Conversation: Hashable {
    let id: String
    let interlocutor: User
    let createdAt: Date
    let state: ConversationState
    let deleteTime: Date?
    
    func with(
        id: String? = nil,
        interlocutor: User? = nil,
        state: ConversationState? = nil,
        deleteTime: Date? = nil,
    ) -> Conversation {
        Conversation(
            id: id ?? self.id,
            interlocutor: interlocutor ?? self.interlocutor,
            createdAt: createdAt,
            state: state ?? self.state,
            deleteTime: deleteTime ?? self.deleteTime
        )
    }
    
    func shouldBeCreated() -> Bool {
        state == .draft ||
        state == .error ||
        state == .deleting
    }
}

enum ConversationState: String, Equatable, Hashable {
    case draft = "draft"
    case creating = "creating"
    case created = "created"
    case deleting = "deleting"
    case error = "error"
}
