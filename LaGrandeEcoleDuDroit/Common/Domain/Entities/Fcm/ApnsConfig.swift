struct ApnsConfig: Codable {
    let headers: ApnsHeaders
    let payload: ApnsPayload
}

struct ApnsHeaders: Codable {
    let apnsPriority: String
    
    init(apnsPriority: String = "10") {
        self.apnsPriority = apnsPriority
    }
}

struct ApnsPayload: Codable {
    let aps: Aps
}

struct Aps: Codable {
    let alert: Alert
    let sound: String
    let badge: Int?

    init(
        alert: Alert,
        sound: String = "default",
        badge: Int? = 1
    ) {
        self.alert = alert
        self.sound = sound
        self.badge = badge
    }
}

struct Alert: Codable {
    let title: String
    let body: String
}
