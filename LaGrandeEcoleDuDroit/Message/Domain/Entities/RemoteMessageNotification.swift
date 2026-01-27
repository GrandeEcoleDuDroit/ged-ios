struct RemoteMessageNotification: Codable {
    let conversation: RemoteMessageNotification.NotificationConversation
    let messageId: String
    let content: String
    let timestamp: Int64
    
    struct NotificationConversation: Codable {
        let id: String
        let interlocutor: OracleUser
        let createdAt: Int64
        let effectiveFrom: Int64?
    }
}
