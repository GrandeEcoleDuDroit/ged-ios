struct RemoteUserReport: Encodable {
    let userId: String
    let reportedUser: RemoteReportedUser
    let reporter: RemoteReporter
    let reason: String
    
    struct RemoteReportedUser: Encodable {
        let fullName: String
        let email: String
    }
    
    struct RemoteReporter: Encodable {
        let fullName: String
        let email: String
    }
}
