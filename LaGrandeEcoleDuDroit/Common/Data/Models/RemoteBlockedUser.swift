import Foundation

struct RemoteBlockedUser: Codable {
    let userId: String
    let blockedUserId: String
    let blockedDate: Int64
    
    enum CodingKeys: String, CodingKey {
        case userId = "USER_ID"
        case blockedUserId = "BLOCKED_USER_ID"
        case blockedDate = "BLOCKED_DATE"
    }
}
