struct RemoteUserReport: Encodable {
    let userId: String
    let userInfo: RemoteUserInfo
    let reporterInfo: RemoteUserInfo
    let reason: String
    
    struct RemoteUserInfo: Encodable {
        let fullName: String
        let email: String
    }
}
