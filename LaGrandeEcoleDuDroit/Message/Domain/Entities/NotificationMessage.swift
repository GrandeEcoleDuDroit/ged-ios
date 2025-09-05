struct NotificationMessage: Codable {
    let conversation: Conversation
    let message: NotificationMessage.MessageContent
    
    struct MessageContent: Codable {
        let content: String
        let date: Int64
    }
}
