import Foundation

struct Conversation: Hashable, Codable, Copyable {
    var id: String
    var interlocutor: User
    var createdAt: Date
    var state: ConversationState
    var deleteTime: Date?
    
    func shouldBeCreated() -> Bool {
        state == .draft ||
        state == .error ||
        state == .deleting
    }
}

enum ConversationState: String, Equatable, Hashable, Codable {
    case draft = "draft"
    case creating = "creating"
    case created = "created"
    case deleting = "deleting"
    case error = "error"
}

extension Conversation {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id &&
            lhs.interlocutor == rhs.interlocutor &&
            lhs.state == rhs.state &&
            lhs.deleteTime == rhs.deleteTime &&
            lhs.createdAt.isAlmostEqual(to: rhs.createdAt)
    }
}
