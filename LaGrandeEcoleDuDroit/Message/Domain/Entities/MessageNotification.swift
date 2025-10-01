struct MessageNotification: Codable {
    let conversation: Conversation
    let message: MessageNotification.MessageContent
    
    struct MessageContent: Codable {
        let content: String
        let date: Int64
    }
}
