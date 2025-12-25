struct RemoteMessageNotification: Codable {
    let conversation: Conversation
    let message: MessageNotification.MessageContent
}
