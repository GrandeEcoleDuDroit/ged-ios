struct AndroidConfig: Encodable {
    let priority: AndroidMessagePriority
    
    init(
        priority: AndroidMessagePriority = .high
    ) {
        self.priority = priority
    }
}

enum AndroidMessagePriority: String, Codable {
    case high = "high"
}
