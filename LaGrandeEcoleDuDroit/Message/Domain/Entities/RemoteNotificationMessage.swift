struct RemoteNotificationMessage: Codable {
    let conversation: RemoteNotificationMessage.Conversation
    let message: NotificationMessage.MessageContent
    
    struct Conversation: Codable {
        let id: String
        let interlocutor: RemoteNotificationMessage.Conversation.Interlocutor
        let createdAt: Int64
        let deleteTime: Int64?
        
        struct Interlocutor: Codable {
            let id: String
            let firstName: String
            let lastName: String
            let fullName: String
            let email: String
            let schoolLevel: String
            let isMember: Bool
            let profilePictureFileName: String?
        }
    }
}
