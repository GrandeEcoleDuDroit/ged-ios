struct RemoteMessageNotification: Codable {
    let conversation: RemoteMessageNotification.Conversation
    let message: MessageNotification.MessageContent
    
    struct Conversation: Codable {
        let id: String
        let interlocutor: RemoteMessageNotification.Conversation.Interlocutor
        let createdAt: Int64
        let deleteTime: Int64?
        
        struct Interlocutor: Codable {
            let id: String
            let firstName: String
            let lastName: String
            let fullName: String
            let email: String
            let schoolLevel: String
            let admin: Bool
            let profilePictureFileName: String?
            let state: String
            let tester: Bool
        }
    }
}
