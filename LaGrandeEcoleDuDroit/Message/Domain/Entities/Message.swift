import Foundation

struct Message: Hashable, Codable, Copying {
    var id: String
    var senderId: String
    var recipientId: String
    var conversationId: String
    var content: String
    var date: Date
    var seen: Bool
    var state: MessageState
    var visible: Bool = true
}

enum MessageState: String, Equatable, Codable {
    case draft = "draft"
    case sending = "sending"
    case sent = "sent"
    case error = "error"
}
