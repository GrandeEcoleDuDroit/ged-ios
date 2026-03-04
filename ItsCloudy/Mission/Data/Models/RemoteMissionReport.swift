struct RemoteMissionReport: Encodable {
    let missionId: String
    let reporter: RemoteReporter
    let reason: String
    
    struct RemoteReporter: Encodable {
        let fullName: String
        let email: String
    }
}
