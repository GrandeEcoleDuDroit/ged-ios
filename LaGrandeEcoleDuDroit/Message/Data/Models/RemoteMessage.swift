import FirebaseFirestore

struct RemoteMessage: Codable {
    let messageId: Int
    let conversationId: String
    let senderId: String
    let recipientId: String
    let content: String
    let timestamp: Timestamp
    let seen: Bool
    
    enum CodingKeys: String, CodingKey {
        case messageId = "messageId"
        case conversationId = "conversationId"
        case senderId = "senderId"
        case recipientId = "recipientId"
        case content = "content"
        case timestamp = "timestamp"
        case seen = "seen"
    }
}
