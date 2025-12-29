protocol BlockedUserApi {
    func getBlockedUserIds(currentUserId: String) async throws -> [String]
    
    func blockUser(currentUserId: String, blockedUserId: String) async throws
    
    func unblockUser(currentUserId: String, blockedUserId: String) async throws
}
