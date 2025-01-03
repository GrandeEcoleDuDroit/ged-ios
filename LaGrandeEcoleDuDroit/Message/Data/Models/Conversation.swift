import Foundation

struct Conversation {
    var id: String
    var interlocutorId: String
    var createdAt: Date = Date.now
    var state: ConversationState
    
    func with(
        id: String? = nil,
        interlocutorId: String? = nil,
        state: ConversationState? = nil
    ) -> Conversation {
        Conversation(
            id: id ?? self.id,
            interlocutorId: interlocutorId ?? self.interlocutorId,
            state: state ?? self.state
        )
    }
}
