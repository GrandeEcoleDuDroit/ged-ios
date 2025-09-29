protocol BlockedUserApi {
    func getBlockedUserIds(currentUserId: String) async throws -> Set<String>
    
    func blockUser(currentUserId: String, userId: String) async throws
    
    func unblockUser(currentUserId: String, userId: String) async throws
}
