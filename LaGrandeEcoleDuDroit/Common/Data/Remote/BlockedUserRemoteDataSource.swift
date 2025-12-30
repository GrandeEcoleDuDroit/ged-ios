import Combine

class BlockedUserRemoteDataSource {
    private let blockedUserApi: BlockedUserApi
    
    init(blockedUserApi: BlockedUserApi) {
        self.blockedUserApi = blockedUserApi
    }
    
    func getBlockedUserIds(currentUserId: String) async throws -> Set<String> {
        try await blockedUserApi.getBlockedUserIds(currentUserId: currentUserId).toSet()
    }
    
    func blockUser(currentUserId: String, blockedUserId: String) async throws {
        try await blockedUserApi.blockUser(currentUserId: currentUserId, blockedUserId: blockedUserId)
    }
    
    func removeBlockedUser(currentUserId: String, blockedUserId: String) async throws {
        try await blockedUserApi.unblockUser(currentUserId: currentUserId, blockedUserId: blockedUserId)
    }
}
