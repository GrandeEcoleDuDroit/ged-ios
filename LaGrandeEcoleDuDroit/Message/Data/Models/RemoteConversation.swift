import FirebaseCore

struct RemoteConversation: Codable {
    let conversationId: String
    let participants: [String]
    let createdAt: Timestamp
    
    enum CodingKeys: String, CodingKey {
        case conversationId = "conversation_id"
        case participants = "participants"
        case createdAt = "created_at"
    }
}
