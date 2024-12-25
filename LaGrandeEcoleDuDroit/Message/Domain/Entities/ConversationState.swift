enum ConversationState {
    case idle
    case notActive
    case active
    case loading
    case creating
    case error(message: String)
}
