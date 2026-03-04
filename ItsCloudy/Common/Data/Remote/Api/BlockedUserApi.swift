import Foundation

protocol BlockedUserApi {
    func getBlockedUsers(currentUserId: String) async throws -> [RemoteBlockedUser]
    
    func addBlockedUser(remoteBlockedUser: RemoteBlockedUser) async throws

    func removeBlockedUser(currentUserId: String, blockedUserId: String) async throws
}
