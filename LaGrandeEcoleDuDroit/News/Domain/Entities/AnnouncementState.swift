enum AnnouncementState: Hashable, CustomStringConvertible {
    case idle
    case sending
    case published
    case deleted
    case updated
    case error
    
    var description: String {
        switch self {
            case .idle: "idle"
            case .sending: "sending"
            case .published: "created"
            case .deleted: "deleted"
            case .updated: "updated"
            case .error: "error"
        }
    }
    
    static func from(description: String) -> AnnouncementState? {
        switch description.lowercased() {
            case "idle": .idle
            case "sending": .sending
            case "created": .published
            case "deleted": .deleted
            case "updated": .updated
            case "error": .error
            default: nil
        }
    }
}
