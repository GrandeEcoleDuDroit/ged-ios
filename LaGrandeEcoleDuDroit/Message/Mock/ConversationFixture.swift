import Foundation

let conversationUiFixture = ConversationUi(
    id: "1",
    interlocutor: userFixture2,
    lastMessage: messageFixture,
    createdAt: Date(),
    state: .created
)

let conversationFixture = Conversation(
    id: "1",
    interlocutor: userFixture2,
    createdAt: Date(),
    state: .created,
    deleteTime: nil
)

let conversationsUiFixture = [
    conversationUiFixture.with(lastMessage: lastMessagesFixture.filter({ $0.conversationId == "1" }).first),
    conversationUiFixture.with(id: "2", lastMessage: lastMessagesFixture.filter({ $0.conversationId == "2" }).first),
    conversationUiFixture.with(id: "3", lastMessage: lastMessagesFixture.filter({ $0.conversationId == "3" }).first),
    conversationUiFixture.with(id: "4", lastMessage: lastMessagesFixture.filter({ $0.conversationId == "4" }).first),
    conversationUiFixture.with(id: "5", lastMessage: lastMessagesFixture.filter({ $0.conversationId == "5" }).first)
]

let conversationsFixture = [
    conversationFixture.with(),
    conversationFixture.with(id: "2"),
    conversationFixture.with(id: "3"),
    conversationFixture.with(id: "4"),
    conversationFixture.with(id: "5")
]
