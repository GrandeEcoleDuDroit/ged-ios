import Combine

class BlockedUserRemoteDataSource {
    private let blockedUserApi: BlockedUserApi
    
    init(blockedUserApi: BlockedUserApi) {
        self.blockedUserApi = blockedUserApi
    }
    
    func getBlockedUserIds(currentUserId: String) async throws -> Set<String> {
        try await blockedUserApi.getBlockedUserIds(currentUserId: currentUserId)
    }
    
    func blockUser(currentUserId: String, userId: String) async throws {
        try await blockedUserApi.blockUser(currentUserId: currentUserId, userId: userId)
    }
    
    func unblockUser(currentUserId: String, userId: String) async throws {
        try await blockedUserApi.unblockUser(currentUserId: currentUserId, userId: userId)
    }
}
