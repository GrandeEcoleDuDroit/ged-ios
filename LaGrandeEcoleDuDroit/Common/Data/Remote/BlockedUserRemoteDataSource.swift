import Combine
import Foundation

class BlockedUserRemoteDataSource {
    private let blockedUserApi: BlockedUserApi
    
    init(blockedUserApi: BlockedUserApi) {
        self.blockedUserApi = blockedUserApi
    }
    
    func getBlockedUsers(currentUserId: String) async throws -> [BlockedUser] {
        try await blockedUserApi.getBlockedUsers(currentUserId: currentUserId).map { $0.toBlockedUser() }
    }
    
    func addBlockedUser(currentUserId: String, blockedUser: BlockedUser) async throws {
        try await blockedUserApi.addBlockedUser(remoteBlockedUser: blockedUser.toRemote(currentUserId: currentUserId))
    }
    
    func removeBlockedUser(currentUserId: String, blockedUserId: String) async throws {
        try await blockedUserApi.removeBlockedUser(currentUserId: currentUserId, blockedUserId: blockedUserId)
    }
}
