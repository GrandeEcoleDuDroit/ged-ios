import Foundation

class NotificationMessageUtils {
    static func formatNotificationId(conversationId: String) -> String {
        let parts = conversationId.components(separatedBy: "_")
        let part1 = parts.first?.prefix(20) ?? ""
        let part2 = parts.last?.suffix(20) ?? ""
        let uuidShort = UUID().uuidString.prefix(6)
        let timestamp = Int(Date().timeIntervalSince1970)
        return "\(part1)_\(part2)_\(timestamp)_\(uuidShort)"
    }
    
    static func getNotificationIdPrefix(conversationId: String) -> String {
        let parts = conversationId.components(separatedBy: "_")
        let part1 = parts.first?.prefix(20) ?? ""
        let part2 = parts.last?.suffix(20) ?? ""
        return "\(part1)_\(part2)"
    }
    
    static func getChannelId() -> String {
        "message_channel_notification_id"
    }
}
