import Combine
import Foundation

class BlockedUserLocalDataSource {
    private let blockedUserKey = "blockedUserKey"
    
    func getBlockedUserIds() -> Set<String> {
        UserDefaults.standard.stringArray(forKey: blockedUserKey)?.toSet() ?? Set<String>()
    }

    func blockUser(blockedUserId: String) -> Set<String> {
        var blockedUserIds = getBlockedUserIds()
        blockedUserIds.insert(blockedUserId)
        UserDefaults.standard.set(Array(blockedUserIds), forKey: blockedUserKey)
        return blockedUserIds
    }
    
    func unblockUser(blockedUserId: String) -> Set<String> {
        var blockedUserIds = getBlockedUserIds()
        blockedUserIds.remove(blockedUserId)
        UserDefaults.standard.set(Array(blockedUserIds), forKey: blockedUserKey)
        return blockedUserIds
    }
}
