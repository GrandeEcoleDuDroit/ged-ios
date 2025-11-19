struct ConversationField {
    struct Local {
        static let conversationId = "conversationId"
        static let conversationCreatedAt = "conversationCreatedAt"
        static let conversationDeleteTime = "conversationDeleteTime"
        static let conversationState = "conversationState"
        static let conversationInterlocutorId = "conversationInterlocutorId"
        static let conversationInterlocutorFirstName = "conversationInterlocutorFirstName"
        static let conversationInterlocutorLastName = "conversationInterlocutorLastName"
        static let conversationInterlocutorEmail = "conversationInterlocutorEmail"
        static let conversationInterlocutorSchoolLevel = "conversationInterlocutorSchoolLevel"
        static let conversationInterlocutorAdmin = "conversationInterlocutorAdmin"
        static let conversationInterlocutorProfilePictureFileName = "conversationInterlocutorProfilePictureFileName"
        static let conversationInterlocutorState = "conversationInterlocutorState"
        static let conversationInterlocutorTester = "conversationInterlocutorTester"
    }
    
    struct Remote {
        static let conversationId = "conversationId"
        static let createdAt = "createdAt"
        static let deleteTime = "deleteTime"
        static let participants = "participants"
    }
}
