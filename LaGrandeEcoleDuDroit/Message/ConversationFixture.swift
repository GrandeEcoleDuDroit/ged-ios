import Foundation

let conversationFixture = Conversation(
    id: "ABCD-EFGH-IJKL-MNOP",
    interlocutor: userFixture,
    message: messageFixture,
    isActive: true
)

let conversationsFixture = [
    conversationFixture.copy(id: "1",message: messagesFixture[0]),
    conversationFixture.copy(id: "2", message: messagesFixture[1]),
    conversationFixture.copy(id: "3", message: messagesFixture[2]),
    conversationFixture.copy(id: "4", message: messagesFixture[3]),
    conversationFixture.copy(id: "5", message: messagesFixture[4]),
]
