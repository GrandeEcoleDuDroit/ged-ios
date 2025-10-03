import Combine
import Foundation

class BlockedUserLocalDataSource {
    private let blockedUserKey = "blockedUserKey"
    
    func getBlockedUserIds() -> Set<String> {
        UserDefaults.standard.stringArray(forKey: blockedUserKey)?.toSet() ?? Set<String>()
    }

    func blockUser(userId: String) -> Set<String> {
        var blockedUserIds = getBlockedUserIds()
        blockedUserIds.insert(userId)
        UserDefaults.standard.set(Array(blockedUserIds), forKey: blockedUserKey)
        return blockedUserIds
    }
    
    func unblockUser(userId: String) -> Set<String> {
        var blockedUserIds = getBlockedUserIds()
        blockedUserIds.remove(userId)
        UserDefaults.standard.set(Array(blockedUserIds), forKey: blockedUserKey)
        return blockedUserIds
    }
}
