struct RemoteAnnouncementReport: Encodable {
    let announcementId: String
    let author: RemoteAuthor
    let reporter: RemoteReporter
    let reason: String
    
    struct RemoteAuthor: Encodable {
        let fullName: String
        let email: String
    }
    
    struct RemoteReporter: Encodable {
        let fullName: String
        let email: String
    }
}
