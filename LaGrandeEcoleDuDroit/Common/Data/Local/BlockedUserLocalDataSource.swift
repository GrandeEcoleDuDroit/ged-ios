import Combine
import Foundation

class BlockedUserLocalDataSource {
    private let blockedUserKey = "blockedUserKey"
    
    func getBlockedUserIds() -> Set<String> {
        let blockedUserIds = UserDefaults.standard.stringArray(forKey: blockedUserKey) ?? []
        return Set(blockedUserIds)
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
