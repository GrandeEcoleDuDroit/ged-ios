import Foundation

enum BlockUserEvent {
    case block(BlockedUser)
    case unblock(blockedUserId: String)
}
