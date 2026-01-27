struct MessageNotification: Codable {
    let conversation: Conversation
    let message: MessageNotification.MessageContent
    
    struct MessageContent: Codable {
        let messageId: String
        let content: String
        let timestamp: Int64
    }
}
