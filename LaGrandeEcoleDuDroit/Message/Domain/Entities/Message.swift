import Foundation

struct Message: Codable, Identifiable, Equatable {
    var id: String
    var conversationId: String
    var content: String
    var date: Date = Date.now
    var isRead: Bool = false
    var senderId: String
    var type: String
    var state: MessageState = .loading
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id &&
        lhs.content == rhs.content &&
        lhs.date == rhs.date &&
        lhs.isRead == rhs.isRead &&
        lhs.senderId == rhs.senderId &&
        lhs.type == rhs.type &&
        lhs.state == rhs.state
    }
    
    func with(
        id: String? = nil,
        conversationId: String? = nil,
        content: String? = nil,
        date: Date? = nil,
        isRead: Bool? = nil,
        senderId: String? = nil,
        type: String? = nil,
        state: MessageState? = nil
    ) -> Message {
        Message(
            id: id ?? self.id,
            conversationId: conversationId ?? self.conversationId,
            content: content ?? self.content,
            date: date ?? self.date,
            isRead: isRead ?? self.isRead,
            senderId: senderId ?? self.senderId,
            type: type ?? self.type,
            state: state ?? self.state
        )
    }
}
