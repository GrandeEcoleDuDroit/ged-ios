import Foundation

struct Message: Codable, Identifiable, Equatable {
    var id: String
    var conversationId: String
    var content: String
    var date: Date
    var isRead: Bool = false
    var senderId: String
    var type: String
    var isSent: Bool
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id &&
        lhs.content == rhs.content &&
        lhs.date == rhs.date &&
        lhs.isRead == rhs.isRead &&
        lhs.senderId == rhs.senderId &&
        lhs.type == rhs.type &&
        lhs.isSent == rhs.isSent
    }
    
    func with(
        id: String? = nil,
        conversationId: String? = nil,
        content: String? = nil,
        date: Date? = nil,
        isRead: Bool? = nil,
        senderId: String? = nil,
        type: String? = nil,
        isSent: Bool? = nil
    ) -> Message {
        Message(
            id: id ?? self.id,
            conversationId: conversationId ?? self.conversationId,
            content: content ?? self.content,
            date: date ?? self.date,
            isRead: isRead ?? self.isRead,
            senderId: senderId ?? self.senderId,
            type: type ?? self.type,
            isSent: self.isSent
        )
    }
}
