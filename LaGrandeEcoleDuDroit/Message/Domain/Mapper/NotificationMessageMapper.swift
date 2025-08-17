import Foundation

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
                    channelId: NotificationMessageUtils.getChannelId()
                )
            ),
            apns: ApnsConfig(
                headers: ApnsHeaders(
                    apnsCollapseId: NotificationMessageUtils.formatNotificationId(conversationId: conversation.id)
                ),
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

