import Foundation

struct Conversation: Hashable, Codable, Copying {
    var id: String
    var interlocutor: User
    var createdAt: Date
    var state: ConversationState
    var effectiveFrom: Date?
    var blockedBy: [String: Bool]?
    
    enum ConversationState: String, Equatable, Hashable, Codable {
        case draft = "draft"
        case creating = "creating"
        case created = "created"
        case deleting = "deleting"
        case error = "error"
    }
}

extension Conversation {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        let sameDeleteTime = switch lhs.effectiveFrom {
            case _ where rhs.effectiveFrom == nil: lhs.effectiveFrom == nil
            case _ where rhs.effectiveFrom != nil: lhs.effectiveFrom?.isAlmostEqual(to: rhs.effectiveFrom!) ?? false
            default: true
        }

        return lhs.id == rhs.id &&
            lhs.interlocutor == rhs.interlocutor &&
            lhs.createdAt.isAlmostEqual(to: rhs.createdAt) &&
            lhs.state == rhs.state &&
            sameDeleteTime
    }
}
