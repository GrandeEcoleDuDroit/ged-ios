let messageContentFixture = MessageNotification.MessageContent(
    content: messageFixture.content,
    date: messageFixture.date.toEpochMilli(),
)

let notificationMessageFixture = MessageNotification(
    conversation: conversationFixture,
    message: messageContentFixture
)
