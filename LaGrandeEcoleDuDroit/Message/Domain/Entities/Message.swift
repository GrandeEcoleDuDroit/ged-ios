import Foundation

struct Message: Hashable {
    let id: Int
    let senderId: String
    let recipientId: String
    let conversationId: String
    let content: String
    let date: Date
    let seen: Bool
    let state: MessageState
    
    func with(
        id: Int? = nil,
        senderId: String? = nil,
        recipientId: String? = nil,
        conversationId: String? = nil,
        content: String? = nil,
        date: Date? = nil,
        seen: Bool? = nil,
        state: MessageState? = nil
    ) -> Message {
        Message(
            id: id ?? self.id,
            senderId: senderId ?? self.senderId,
            recipientId: recipientId ?? self.recipientId,
            conversationId: conversationId ?? self.conversationId,
            content: content ?? self.content,
            date: date ?? self.date,
            seen: seen ?? self.seen,
            state: state ?? self.state
        )
    }
}

enum MessageState: String, Equatable, Codable {
    case draft = "draft"
    case loading = "loading"
    case sent = "sent"
    case error = "error"
}

