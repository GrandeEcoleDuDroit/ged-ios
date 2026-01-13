extension ConversationUi {
    func toConversation() -> Conversation {
        Conversation(
            id: id,
            interlocutor: interlocutor,
            createdAt: createdAt,
            state: state,
            effectiveFrom: nil
        )
    }
}

extension Conversation {
    func toConversationUI(message: Message) -> ConversationUi {
        ConversationUi(
            id: id,
            interlocutor: interlocutor,
            lastMessage: message,
            createdAt: createdAt,
            state: state
        )
    }
}

extension ConversationMessage {
    func toConversationUi() -> ConversationUi {
       ConversationUi(
            id: conversation.id,
            interlocutor: conversation.interlocutor,
            lastMessage: lastMessage,
            createdAt: conversation.createdAt,
            state: conversation.state
        )
    }
}
