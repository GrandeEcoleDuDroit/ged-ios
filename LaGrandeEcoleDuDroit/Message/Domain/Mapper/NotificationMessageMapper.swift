let messageChannelNotificationId = "message_channel_notification_id"

extension NotificationMessage {
    func toFcm(user: User) -> FcmMessage<NotificationMessage> {
        FcmMessage(
            notification: FcmNotification(
                title: user.fullName,
                body: message.content
            ),
            data: FcmData(
                type: FcmDataType.message,
                value: NotificationMessage(
                    conversation: conversation.with(interlocutor: user),
                    message: message
                )
            ),
            android: AndroidConfig(
                notification: AndroidNotification(
                    channelId: messageChannelNotificationId
                )
            ),
            apns: ApnsConfig(
                headers: ApnsHeaders(),
                payload: ApnsPayload(
                    aps: Aps(
                        alert: Alert(
                            title: user.fullName,
                            body: message.content
                        )
                    )
                )
            )
        )
    }
}

