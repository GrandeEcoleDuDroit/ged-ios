struct RemoteAnnouncementReport: Encodable {
    let announcementId: String
    let authorInfo: RemoteUserInfo
    let userInfo: RemoteUserInfo
    let reason: String
    
    struct RemoteUserInfo: Encodable {
        let fullName: String
        let email: String
    }
}
