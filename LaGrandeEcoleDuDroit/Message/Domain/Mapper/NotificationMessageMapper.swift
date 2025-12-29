import Foundation

extension MessageNotification {
    func toFcm(user: User) -> FcmMessage<MessageNotification> {
        FcmMessage(
            notification: FcmNotification(
                title: user.fullName,
                body: message.content
            ),
            data: FcmData(
                type: FcmDataType.message,
                value: MessageNotification(
                    conversation: conversation.copy { $0.interlocutor = user },
                    message: message
                )
            ),
            android: AndroidConfig(
                notification: AndroidNotification(
                    channelId: NotificationMessageUtils.channelId
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
    
    func toRemote(currentUser: User) -> RemoteMessageNotification {
        RemoteMessageNotification(
            conversation: Conversation(
                id: conversation.id,
                interlocutor: currentUser,
                createdAt: conversation.createdAt,
                state: conversation.state,
                effectiveFrom: conversation.effectiveFrom
            ),
            message: message
        )
    }
}

extension RemoteMessageNotification {
    func toFcm() -> FcmMessage<RemoteMessageNotification> {
        FcmMessage(
            notification: FcmNotification(
                title: conversation.interlocutor.fullName,
                body: message.content
            ),
            data: FcmData(
                type: FcmDataType.message,
                value: self
            ),
            android: AndroidConfig(
                notification: AndroidNotification(
                    channelId: NotificationMessageUtils.channelId
                )
            ),
            apns: ApnsConfig(
                headers: ApnsHeaders(
                    apnsCollapseId: NotificationMessageUtils.formatNotificationId(conversationId: conversation.id)
                ),
                payload: ApnsPayload(
                    aps: Aps(
                        alert: Alert(
                            title: conversation.interlocutor.fullName,
                            body: message.content
                        )
                    )
                )
            )
        )
    }
    
    func toNotificationMessage() -> MessageNotification {
        MessageNotification(
            conversation: conversation,
            message: message
        )
    }
}
