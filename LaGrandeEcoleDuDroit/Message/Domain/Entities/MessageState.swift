enum MessageState: String, Equatable, Codable {
    case sent = "sent"
    case error = "error"
    case loading = "loading"
    
    static func from(_ value: String) -> MessageState? {
        switch value {
            case "sent": .sent
            case "error": .error
            case "loading": .loading
            default: nil
        }
    }
}
