enum ConversationField : String, CodingKey {
    case conversationId = "conversationId"
    case createdAt = "createdAt"
    case deleteTime = "deleteTime"
    
    enum Remote : String, CodingKey{
        case participants = "participants"
    }
    
    enum Local : String, CodingKey{
        case state = "state"
        case interlocutorId = "interlocutorId"
        case interlocutorFirstName = "interlocutorFirstName"
        case interlocutorLastName = "interlocutorLastName"
        case interlocutorEmail = "interlocutorEmail"
        case interlocutorSchoolLevel = "interlocutorSchoolLevel"
        case interlocutorIsMember = "interlocutorIsMember"
        case interlocutorProfilePictureFileName = "interlocutorProfilePictureFileName"
    }
}

enum MessageField : String, CodingKey {
    case messageId = "messageId"
    case conversationId = "conversationId"
    case senderId = "senderId"
    case recipientId = "recipientId"
    case content = "content"
    case timestamp = "timestamp"
    case seen = "seen"
    
    enum Local : String, CodingKey {
        case state = "state"
    }
}
