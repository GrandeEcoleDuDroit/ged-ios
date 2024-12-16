import FirebaseFirestore

struct RemoteMessage: Codable {
    let messageId: String
    let conversationId: String
    let senderId: String
    let content: String
    let timestamp: Timestamp
    let isRead: Bool
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case content = "content"
        case timestamp = "timestamp"
        case isRead = "is_read"
        case type = "type"
    }
}
