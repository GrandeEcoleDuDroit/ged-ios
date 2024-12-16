import Foundation

let conversationUIFixture = ConversationUI(
    id: "1",
    interlocutor: userFixture,
    lastMessage: messageFixture
)

let conversationUserFixture = ConversationUser(
    id: "1",
    interlocutor: userFixture
)

let conversationsUIFixture = [
    conversationUIFixture.with(lastMessage: messagesFixture[0]),
    conversationUIFixture.with(id: "2", lastMessage: messagesFixture[1]),
    conversationUIFixture.with(id: "3", lastMessage: messagesFixture[2]),
    conversationUIFixture.with(id: "4", lastMessage: messagesFixture[3]),
    conversationUIFixture.with(id: "5", lastMessage: messagesFixture[4])
]

let conversationsUserFixture = [
//    conversationUserFixture,
//    conversationUserFixture.with(id: "2"),
    conversationUserFixture.with(id: "3"),
    conversationUserFixture.with(id: "4"),
//    conversationUserFixture.with(id: "5")
]
