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
    
    func toRemote(currentUser: User) -> RemoteNotificationMessage {
        RemoteNotificationMessage(
            conversation: RemoteNotificationMessage.Conversation(
                id: conversation.id,
                interlocutor: currentUser.toIntelocutor(),
                createdAt: conversation.createdAt.toEpochMilli(),
                deleteTime: conversation.deleteTime?.toEpochMilli()
            ),
            message: message
        )
    }
}

extension RemoteNotificationMessage {
    func toFcm() -> FcmMessage<RemoteNotificationMessage> {
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
    
    func toNotificationMessage() -> NotificationMessage {
        NotificationMessage(
            conversation: conversation.toConversation(),
            message: message
        )
    }
}

private extension User {
    func toIntelocutor() -> RemoteNotificationMessage.Conversation.Interlocutor {
        RemoteNotificationMessage.Conversation.Interlocutor(
            id: id,
            firstName: firstName,
            lastName: lastName,
            fullName: fullName,
            email: email,
            schoolLevel: schoolLevel.rawValue,
            isMember: isMember,
            profilePictureFileName: UrlUtils.getFileNameFromUrl(url: profilePictureUrl)
        )
    }
}

private extension RemoteNotificationMessage.Conversation {
    func toConversation() -> Conversation {
        Conversation(
            id: id,
            interlocutor: interlocutor.toUser(),
            createdAt: createdAt.toDate(),
            state: .created,
            deleteTime: deleteTime?.toDate()
        )
    }
}

private extension RemoteNotificationMessage.Conversation.Interlocutor {
    func toUser() -> User {
        User(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            schoolLevel: SchoolLevel(rawValue: schoolLevel) ?? .ged1,
            isMember: isMember,
            profilePictureUrl: UrlUtils.formatProfilePictureUrl(fileName: profilePictureFileName)
        )
    }
}

