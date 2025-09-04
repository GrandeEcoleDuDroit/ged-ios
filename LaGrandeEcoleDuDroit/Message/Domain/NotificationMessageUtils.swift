import Foundation

class NotificationMessageUtils {
    static func formatNotificationId(conversationId: String) -> String {
        let notificationIdPrefix = formatNotificationIdPrefix(conversationId: conversationId)
        let uuidShort = UUID().uuidString.prefix(6)
        let timestamp = Int(Date().timeIntervalSince1970)
        return "\(notificationIdPrefix)_\(timestamp)_\(uuidShort)"
    }
    
    static func formatNotificationIdPrefix(conversationId: String) -> String {
        let parts = conversationId.components(separatedBy: "_")
        let part1 = parts.first?.prefix(20) ?? ""
        let part2 = parts.last?.suffix(20) ?? ""
        return "\(part1)_\(part2)"
    }
    
    static let channelId: String = "message_channel_notification_id"
}
