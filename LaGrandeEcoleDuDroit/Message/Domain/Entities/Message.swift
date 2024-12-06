import Foundation

struct Message: Hashable {
    let id: String
    let content: String
    let date: Date
    var isRead: Bool = false
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
    
    func copy(
        id: String? = nil,
        content: String? = nil,
        date: Date? = nil,
        isRead: Bool? = nil
    ) -> Message {
        Message(
            id: id ?? self.id,
            content: content ?? self.content,
            date: date ?? self.date,
            isRead: isRead ?? self.isRead
        )
    }
}
