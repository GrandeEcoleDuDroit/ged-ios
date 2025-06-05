import FirebaseCore

struct RemoteConversation: Codable {
    let conversationId: String
    let participants: [String]
    let createdAt: Timestamp
    let deleteTime: [String: Timestamp]?
    
    enum CodingKeys: String, CodingKey {
        case conversationId = "conversationId"
        case participants = "participants"
        case createdAt = "createdAt"
        case deleteTime = "deleteTime"
    }
}
