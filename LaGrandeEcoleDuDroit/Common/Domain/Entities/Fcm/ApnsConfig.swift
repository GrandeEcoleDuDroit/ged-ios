struct ApnsConfig: Codable {
    let headers: ApnsHeaders
    let payload: ApnsPayload
}

struct ApnsHeaders: Codable {
    let apnsPushType: String
    let apnsPriority: String
    let apnsCollapseId: String
    
    init(
        apnsPushType: String = "alert",
        apnsPriority: String = "10",
        apnsCollapseId: String
    ) {
        self.apnsPushType = apnsPushType
        self.apnsPriority = apnsPriority
        self.apnsCollapseId = apnsCollapseId
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
