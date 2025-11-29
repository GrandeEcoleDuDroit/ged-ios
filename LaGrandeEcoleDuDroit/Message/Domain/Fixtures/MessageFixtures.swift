import Foundation

private let currentDate = Date()

let messageFixture = Message(
    id: "1",
    senderId: userFixture.id,
    recipientId: userFixture2.id,
    conversationId: "1",
    content: "Hi, how are you ?",
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
        recipientId: userFixture2.id,
        conversationId: "1",
        content: "Hi, how are you ?",
        date: Date(),
        seen: true,
        state: .sent
    ),
    Message(
        id: "2",
        senderId: userFixture.id,
        recipientId: userFixture2.id,
        conversationId: "1",
        content: "Hi, how are you ?",
        date: currentDate.minusMinutes(10),
        seen: false,
        state: .error
    ),
    Message(
        id: "3",
        senderId: userFixture2.id,
        recipientId: userFixture.id,
        conversationId: "1",
        content: "Fine, and you ?",
        date: currentDate.minusMinutes(5),
        seen: true,
        state: .sent
    ),
    Message(
        id: "4",
        senderId: userFixture.id,
        recipientId: userFixture2.id,
        conversationId: "1",
        content: "Fine, thanks !",
        date: currentDate.minusMinutes(2),
        seen: true,
        state: .sent
    ),
    Message(
        id: "5",
        senderId: userFixture2.id,
        recipientId: userFixture.id,
        conversationId: "1",
        content: "Great !",
        date: currentDate.minusMinutes(1),
        seen: true,
        state: .sent
    ),
    Message(
        id: "6",
        senderId: userFixture.id,
        recipientId: userFixture2.id,
        conversationId: "1",
        content: "Ok, see you later !",
        date: currentDate,
        seen: false,
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
        date: currentDate.minusMinutes(10),
        seen: true,
        state: .sent
    ),
    Message(
        id: "1",
        senderId: userFixture.id,
        recipientId: userFixture2.id,
        conversationId: "2",
        content: "Last message conversation 2",
        date: currentDate.minusMinutes(5),
        seen: true,
        state: .sent
    ),
    Message(
        id: "1",
        senderId: userFixture.id,
        recipientId: userFixture2.id,
        conversationId: "3",
        content: "Last message conversation 3",
        date: currentDate.minusMinutes(2),
        seen: true,
        state: .sent
    ),
    Message(
        id: "1",
        senderId: userFixture.id,
        recipientId: userFixture2.id,
        conversationId: "4",
        content: "Last message conversation 4",
        date: currentDate.minusMinutes(1),
        seen: true,
        state: .sent
    ),
    Message(
        id: "1",
        senderId: userFixture.id,
        recipientId: userFixture2.id,
        conversationId: "5",
        content: "Last message conversation 5",
        date: currentDate,
        seen: false,
        state: .sent
    )
]
