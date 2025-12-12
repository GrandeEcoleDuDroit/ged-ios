import Foundation

struct ConversationUi: Hashable, Identifiable, Copyable, Equatable {
    var id: String
    var interlocutor: User
    var lastMessage: Message
    var createdAt: Date
    var state: ConversationState
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
