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
        state: ConversationState? = nil
    ) -> Conversation {
        Conversation(
            id: id ?? self.id,
            interlocutor: interlocutor ?? self.interlocutor,
            createdAt: createdAt,
            state: state ?? self.state,
            deleteTime: deleteTime
        )
    }
    
    func shouldBeCreated() -> Bool {
         state == .draft || state == .error
    }
}

enum ConversationState: String, Equatable, Hashable {
    case draft = "draft"
    case loading = "loading"
    case created = "created"
    case error = "error"
}
