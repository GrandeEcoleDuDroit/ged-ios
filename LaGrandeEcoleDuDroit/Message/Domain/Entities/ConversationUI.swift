import Foundation

struct ConversationUi: Identifiable, Copying, Equatable {
    var id: String
    var interlocutor: User
    var lastMessage: Message
    var createdAt: Date
    var state: Conversation.ConversationState
}
