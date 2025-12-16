import Foundation

struct Conversation: Hashable, Codable, Copying {
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
        let sameDeleteTime = switch lhs.deleteTime {
            case _ where rhs.deleteTime == nil: lhs.deleteTime == nil
            case _ where rhs.deleteTime != nil: lhs.deleteTime?.isAlmostEqual(to: rhs.deleteTime!) ?? false
            default: true
        }

        return lhs.id == rhs.id &&
            lhs.interlocutor == rhs.interlocutor &&
            lhs.createdAt.isAlmostEqual(to: rhs.createdAt) &&
            lhs.state == rhs.state &&
            sameDeleteTime
    }
}
