struct MessageField {
    struct Remote {
        static let messageId = "messageId"
        static let conversationId = "conversationId"
        static let senderId = "senderId"
        static let recipientId = "recipientId"
        static let content = "content"
        static let timestamp = "timestamp"
        static let seen = "seen"
    }
    
    struct Local {
        static let messageId = "messageId"
        static let messageConversationId = "messageConversationId"
        static let messageSenderId = "messageSenderId"
        static let messageRecipientId = "messageRecipientId"
        static let messageContent = "messageContent"
        static let messageDate = "messageDate"
        static let messageSeen = "messageSeen"
        static let messageState = "messageState"
    }
}
