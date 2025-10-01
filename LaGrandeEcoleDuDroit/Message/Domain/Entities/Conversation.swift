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
