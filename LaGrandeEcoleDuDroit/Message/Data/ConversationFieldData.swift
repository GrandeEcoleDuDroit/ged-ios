struct ConversationField {
    struct Local {
        static let conversationId = "conversationId"
        static let conversationCreatedAt = "conversationCreatedAt"
        static let conversationEffectiveFrom = "conversationEffectiveFrom"
        static let conversationBlockedBy = "conversationBlockedBy"
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
        static let effectiveFrom = "effectiveFrom"
        static let participants = "participants"
        static let blockedBy = "blockedBy"
    }
}
