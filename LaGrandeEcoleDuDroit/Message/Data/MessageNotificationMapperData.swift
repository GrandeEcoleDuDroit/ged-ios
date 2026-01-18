import Foundation

extension MessageNotification {
    func toRemote(currentUser: User) -> RemoteMessageNotification {
        RemoteMessageNotification(
            conversation: RemoteMessageNotification.NotificationConversation(
                id: conversation.id,
                interlocutor: currentUser.toOracleUser(),
                createdAt: conversation.createdAt.toEpochMilli(),
                effectiveFrom: conversation.effectiveFrom?.toEpochMilli()
            ),
            messageId: message.messageId,
            content: message.content,
            timestamp: message.timestamp
        )
    }
}

extension RemoteMessageNotification {
    func toFcm() -> FcmMessage<RemoteMessageNotification> {
        FcmMessage(
            data: FcmData(
                type: FcmDataType.message,
                value: self
            ),
            android: AndroidConfig(),
            apns: ApnsConfig(
                headers: ApnsHeaders(
                    apnsCollapseId: MessageNotificationUtils.formatNotificationId(conversationId: conversation.id)
                ),
                payload: ApnsPayload(
                    aps: Aps(
                        alert: Alert(
                            title: conversation.interlocutor.toUser().fullName,
                            body: content
                        )
                    )
                )
            )
        )
    }
    
    func toMessageNotification() -> MessageNotification {
        MessageNotification(
            conversation: Conversation(
                id: conversation.id,
                interlocutor: conversation.interlocutor.toUser(),
                createdAt: conversation.createdAt.toDate(),
                state: .created
            ),
            message: MessageNotification.MessageContent(
                messageId: messageId,
                content: content,
                timestamp: timestamp
            )
        )
    }
}
