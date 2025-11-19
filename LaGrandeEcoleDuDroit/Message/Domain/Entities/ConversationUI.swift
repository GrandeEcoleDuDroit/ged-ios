import Foundation

struct ConversationUi: Identifiable, Copyable, Equatable {
    var id: String
    var interlocutor: User
    var lastMessage: Message
    var createdAt: Date
    var state: ConversationState
}
