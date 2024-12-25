import Foundation

struct Conversation {
    var id: String
    var interlocutorId: String
    var createdAt: Date = Date.now
    var isCreated: Bool = false
    
    func with(
        id: String? = nil,
        interlocutorId: String? = nil
    ) -> Conversation {
        Conversation(
            id: id ?? self.id,
            interlocutorId: interlocutorId ?? self.interlocutorId
        )
    }
}
