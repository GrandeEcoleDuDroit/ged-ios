struct RemoteMessageReport: Encodable {
    let conversationId: String
    let messageId: String
    let recipientInfo: RemoteUserInfo
    let reason: String
    
    struct RemoteUserInfo: Encodable {
        let fullName: String
        let email: String
    }
}
