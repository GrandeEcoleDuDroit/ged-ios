import Foundation

let conversationFixture = Conversation(
    id: "1",
    interlocutor: userFixture2,
    createdAt: Date(),
    state: .created,
    deleteTime: nil
)

let conversationsFixture = [
    conversationFixture.with(),
    conversationFixture.with(id: "2"),
    conversationFixture.with(id: "3"),
    conversationFixture.with(id: "4"),
    conversationFixture.with(id: "5")
]

let conversationUiFixture = ConversationUi(
    id: "1",
    interlocutor: userFixture2,
    lastMessage: messageFixture,
    createdAt: Date(),
    state: .created
)

let conversationsUiFixture = [
    conversationUiFixture.with(lastMessage: messageFixture)
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
