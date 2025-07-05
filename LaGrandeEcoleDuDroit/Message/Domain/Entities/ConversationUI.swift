import Foundation

struct ConversationUi: Equatable {
    let id: String
    let interlocutor: User
    let lastMessage: Message
    let createdAt: Date
    let state: ConversationState
    
    func with(
        id: String? = nil,
        interlocutor: User? = nil,
        lastMessage: Message? = nil,
        createdAt: Date? = nil,
        state: ConversationState? = nil
    ) -> ConversationUi {
        ConversationUi(
            id: id ?? self.id,
            interlocutor: interlocutor ?? self.interlocutor,
            lastMessage: lastMessage ?? self.lastMessage,
            createdAt: createdAt ?? self.createdAt,
            state: state ?? self.state
        )
    }
}
