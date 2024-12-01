enum AnnouncementState: Hashable, CustomStringConvertible {
    case idle
    case loading
    case created
    case deleted
    case updated
    case error(message: String)
    
    var description: String {
        switch self {
        case .idle:
            "idle"
        case .loading:
            "loading"
        case .created:
            "created"
        case .deleted:
            "deleted"
        case .updated:
            "updated"
        case .error(_):
            "error"
        }
    }
    
    static func from(description: String) -> AnnouncementState? {
        switch description.lowercased() {
        case "idle":
            return .idle
        case "loading":
            return .loading
        case "created":
            return .created
        case "error":
            return .error(message: "")
        default:
            return nil
        }
    }
}
