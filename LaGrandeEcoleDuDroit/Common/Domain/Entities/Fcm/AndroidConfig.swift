struct AndroidConfig: Encodable {
    let priority: AndroidMessagePriority
    let notification: AndroidNotification
    
    init(
        priority: AndroidMessagePriority = .high,
        notification: AndroidNotification
    ) {
        self.priority = priority
        self.notification = notification
    }
}

enum AndroidMessagePriority: String, Codable {
    case high = "high"
}

struct AndroidNotification: Encodable {
    let channelId: String
    let icon: String = "ic_notification"
    
    enum CodingKeys: String, CodingKey {
        case channelId = "channel_id"
    }
}
