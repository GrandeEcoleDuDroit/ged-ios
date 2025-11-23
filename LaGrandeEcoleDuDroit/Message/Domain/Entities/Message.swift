import Foundation

struct Message: Hashable, Codable, Copyable {
    var id: String
    var senderId: String
    var recipientId: String
    var conversationId: String
    var content: String
    var date: Date
    var seen: Bool
    var state: MessageState
}

enum MessageState: String, Equatable, Codable {
    case draft = "draft"
    case sending = "sending"
    case sent = "sent"
    case error = "error"
}
