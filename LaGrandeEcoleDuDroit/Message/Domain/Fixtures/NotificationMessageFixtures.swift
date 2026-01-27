let messageContentFixture = MessageNotification.MessageContent(
    messageId: messageFixture.id,
    content: messageFixture.content,
    timestamp: messageFixture.date.toEpochMilli(),
)

let notificationMessageFixture = MessageNotification(
    conversation: conversationFixture,
    message: messageContentFixture
)
