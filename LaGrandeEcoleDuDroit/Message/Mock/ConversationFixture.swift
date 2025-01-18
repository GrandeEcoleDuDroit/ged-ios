import Foundation

let conversationUIFixture = ConversationUI(
    id: "1",
    interlocutor: userFixture2,
    lastMessage: messageFixture,
    state: .created
)

let conversationUserFixture = ConversationUser(
    id: "1",
    interlocutor: userFixture2,
    state: .created
)

let conversationsUIFixture = [
    conversationUIFixture.with(lastMessage: lastMessagesFixture.filter({ $0.conversationId == "1" }).first),
    conversationUIFixture.with(id: "2", lastMessage: lastMessagesFixture.filter({ $0.conversationId == "2" }).first),
    conversationUIFixture.with(id: "3", lastMessage: lastMessagesFixture.filter({ $0.conversationId == "3" }).first),
    conversationUIFixture.with(id: "4", lastMessage: lastMessagesFixture.filter({ $0.conversationId == "4" }).first),
    conversationUIFixture.with(id: "5", lastMessage: lastMessagesFixture.filter({ $0.conversationId == "5" }).first)
]

var conversationsUserFixture = [
    conversationUserFixture,
    conversationUserFixture.with(id: "2"),
    conversationUserFixture.with(id: "3"),
    conversationUserFixture.with(id: "4"),
    conversationUserFixture.with(id: "5")
]
