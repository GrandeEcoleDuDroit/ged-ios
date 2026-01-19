import Foundation


let messageFixture = Message(
    id: "1",
    senderId: userFixture2.id,
    recipientId: userFixture.id,
    conversationId: "1",
    content: "Salut, comment tu vas ?",
    date: Date(),
    seen: true,
    state: .sent
)

let messageFixture2 = Message(
    id: "1",
    senderId: userFixture.id,
    recipientId: userFixture2.id,
    conversationId: "1",
    content: "Bonjour, j'espère que vous allez bien. " +
            "Je voulais prendre un moment pour vous parler de quelque chose d'important. " +
            "En fait, je pense qu'il est essentiel que nous discutions de la direction que prend notre projet, " +
            "car il y a plusieurs points que nous devrions clarifier.",
    date: Date(),
    seen: true,
    state: .sent
)

let messagesFixture = [
    Message(
        id: "1",
        senderId: userFixture.id,
        recipientId: usersFixture[1].id,
        conversationId: conversationFixture.id,
        content: "On s'y retrouve à 14h. 👍",
        date: Date(),
        seen: true,
        state: .sent
    ),
    Message(
        id: "2",
        senderId: usersFixture[1].id,
        recipientId: userFixture.id,
        conversationId: conversationFixture.id,
        content: "Top ! Ca va être super.",
        date: Date().minusMinutes(1),
        seen: true,
        state: .sent
    ),
    Message(
        id: "4",
        senderId: userFixture.id,
        recipientId: usersFixture[1].id,
        conversationId: conversationFixture.id,
        content: "J'ai ramené quelques cousins venu de l'étranger.",
        date: Date().minusMinutes(3),
        seen: true,
        state: .sent
    ),
    Message(
        id: "5",
        senderId: usersFixture[1].id,
        recipientId: userFixture.id,
        conversationId: conversationFixture.id,
        content: "Je suis en route..",
        date: Date().minusMinutes(4),
        seen: true,
        state: .sent
    ),
    Message(
        id: "6",
        senderId: userFixture.id,
        recipientId: usersFixture[1].id,
        conversationId: conversationFixture.id,
        content: "On m'a signalé que l'événement avait commencé.",
        date: Date().minusMinutes(5),
        seen: true,
        state: .sent
    )
]

let lastMessagesFixture = [
    Message(
        id: "1",
        senderId: userFixture.id,
        recipientId: userFixture2.id,
        conversationId: "1",
        content: "Last message conversation 1",
        date: Date().minusMinutes(10),
        seen: true,
        state: .sent
    ),
    Message(
        id: "1",
        senderId: userFixture.id,
        recipientId: userFixture2.id,
        conversationId: "2",
        content: "Last message conversation 2",
        date: Date().minusMinutes(5),
        seen: true,
        state: .sent
    ),
    Message(
        id: "1",
        senderId: userFixture.id,
        recipientId: userFixture2.id,
        conversationId: "3",
        content: "Last message conversation 3",
        date: Date().minusMinutes(2),
        seen: true,
        state: .sent
    ),
    Message(
        id: "1",
        senderId: userFixture.id,
        recipientId: userFixture2.id,
        conversationId: "4",
        content: "Last message conversation 4",
        date: Date().minusMinutes(1),
        seen: true,
        state: .sent
    ),
    Message(
        id: "1",
        senderId: userFixture.id,
        recipientId: userFixture2.id,
        conversationId: "5",
        content: "Last message conversation 5",
        date: Date(),
        seen: false,
        state: .sent
    )
]

