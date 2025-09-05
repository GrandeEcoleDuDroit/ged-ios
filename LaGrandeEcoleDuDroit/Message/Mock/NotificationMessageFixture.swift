let messageContentFixture = NotificationMessage.MessageContent(
    content: messageFixture.content,
    date: messageFixture.date.toEpochMilli(),
)

let notificationMessageFixture = NotificationMessage(
    conversation: conversationFixture,
    message: messageContentFixture
)
