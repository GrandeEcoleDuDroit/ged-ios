import Foundation

enum BlockUserEvent {
    case block(userId: String, date: Date = Date())
    case unblock(userId: String, date: Date = Date())
}
