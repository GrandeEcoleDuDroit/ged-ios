enum ConversationState: Equatable {
    case idle
    case notCreated
    case loading
    case creating
    case created
    case error(message: String)
}
