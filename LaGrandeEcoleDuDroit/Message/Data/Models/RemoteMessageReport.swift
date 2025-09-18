struct RemoteMessageReport: Encodable {
    let conversationId: String
    let messageId: Int64
    let recipientInfo: RemoteUserInfo
    let reason: String
    
    struct RemoteUserInfo: Encodable {
        let fullName: String
        let email: String
    }
}
