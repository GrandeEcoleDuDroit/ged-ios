import Foundation

let conversationFixture = Conversation(
    id: "1",
    interlocutor: userFixture2,
    createdAt: Date(),
    state: .created,
    deleteTime: nil
)

let conversationsFixture = [
    conversationFixture,
    conversationFixture.copy { $0.id = "2" },
    conversationFixture.copy { $0.id = "3" },
    conversationFixture.copy { $0.id = "4" },
    conversationFixture.copy { $0.id = "5" }
]

let conversationUiFixture = ConversationUi(
    id: "1",
    interlocutor: userFixture2,
    lastMessage: messageFixture,
    createdAt: Date(),
    state: .created
)

let conversationsUiFixture = [
    conversationUiFixture.copy { $0.lastMessage = messageFixture },
    conversationUiFixture.copy { $0.id = "2" },
    conversationUiFixture.copy { $0.id = "3" },
    conversationUiFixture.copy { $0.id = "4" },
    conversationUiFixture.copy { $0.id = "5" },
    conversationUiFixture.copy { $0.id = "6" },
    conversationUiFixture.copy { $0.id = "7" }
]

let conversationMessageFixture = ConversationMessage(
    conversation: conversationFixture,
    lastMessage: messageFixture
)

let conversationMessagesFixture = conversationsUiFixture.map { conversationUi in
    ConversationMessage(
        conversation: conversationUi.toConversation(),
        lastMessage: conversationUi.lastMessage
    )
}
