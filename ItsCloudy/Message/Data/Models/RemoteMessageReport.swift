struct RemoteMessageReport: Encodable {
    let conversationId: String
    let messageId: String
    let recipient: RemoteRecipient
    let reason: String
    
    struct RemoteRecipient: Encodable {
        let fullName: String
        let email: String
    }
}
