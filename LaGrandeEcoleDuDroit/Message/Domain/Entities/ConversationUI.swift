import Foundation

struct ConversationUi: Identifiable, Copying, Equatable, Hashable {
    var id: String
    var interlocutor: User
    var lastMessage: Message
    var createdAt: Date
    var state: Conversation.ConversationState
    
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
