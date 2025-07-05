struct ConversationField {
    static let conversationId = "conversationId"
    static let createdAt = "createdAt"
    static let deleteTime = "deleteTime"
    
    struct Remote {
        static let participants = "participants"
    }
    
    struct Local {
        static let state = "state"
        static let interlocutorId = "interlocutorId"
        static let interlocutorFirstName = "interlocutorFirstName"
        static let interlocutorLastName = "interlocutorLastName"
        static let interlocutorEmail = "interlocutorEmail"
        static let interlocutorSchoolLevel = "interlocutorSchoolLevel"
        static let interlocutorIsMember = "interlocutorIsMember"
        static let interlocutorProfilePictureFileName = "interlocutorProfilePictureFileName"
    }
}

struct MessageField {
    static let messageId = "messageId"
    static let conversationId = "conversationId"
    static let senderId = "senderId"
    static let recipientId = "recipientId"
    static let content = "content"
    static let timestamp = "timestamp"
    static let seen = "seen"
    
    struct Local {
        static let state = "state"
    }
}
