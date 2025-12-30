import Combine
import Foundation

class BlockedUserLocalDataSource {
    private let blockedUserKey = "blockedUserKey"
    
    func getBlockedUserIds() -> Set<String> {
        UserDefaults.standard.stringArray(forKey: blockedUserKey)?.toSet() ?? Set<String>()
    }

    func addBlockedUser(blockedUserId: String) {
        var blockedUserIds = getBlockedUserIds()
        blockedUserIds.insert(blockedUserId)
        UserDefaults.standard.set(Array(blockedUserIds), forKey: blockedUserKey)
    }
    
    func removeBlockedUser(blockedUserId: String) {
        var blockedUserIds = getBlockedUserIds()
        blockedUserIds.remove(blockedUserId)
        UserDefaults.standard.set(Array(blockedUserIds), forKey: blockedUserKey)
    }
    
    func deleteAll() {
        UserDefaults.standard.removeObject(forKey: blockedUserKey)
    }
}
