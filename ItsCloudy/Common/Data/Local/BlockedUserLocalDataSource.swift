import Combine
import Foundation

class BlockedUserLocalDataSource {
    private let blockedUserKey = "blockedUserKey"
    
    func getBlockedUsers() -> [String: BlockedUser] {
        var blockedUsers: [String: BlockedUser]?
        if let data = UserDefaults.standard.data(forKey: blockedUserKey) {
            blockedUsers = try? JSONDecoder().decode([String: BlockedUser].self, from: data)
        }
        return blockedUsers ?? [:]
    }

    func addBlockedUser(blockedUser: BlockedUser) throws {
        var blockedUsers = getBlockedUsers()
        blockedUsers[blockedUser.userId] = blockedUser
        let data = try JSONEncoder().encode(blockedUsers)
        UserDefaults.standard.set(data, forKey: blockedUserKey)
    }
    
    func removeBlockedUser(userId: String) throws {
        var blockedUsers = getBlockedUsers()
        blockedUsers[userId] = nil
        let data = try JSONEncoder().encode(blockedUsers)
        UserDefaults.standard.set(data, forKey: blockedUserKey)
    }
    
    func deleteAll() {
        UserDefaults.standard.removeObject(forKey: blockedUserKey)
    }
}
