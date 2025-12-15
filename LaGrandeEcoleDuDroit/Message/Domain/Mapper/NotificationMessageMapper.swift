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
            conversation: RemoteMessageNotification.Conversation(
                id: conversation.id,
                interlocutor: currentUser.toIntelocutor(),
                createdAt: conversation.createdAt.toEpochMilli(),
                deleteTime: conversation.deleteTime?.toEpochMilli()
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
            conversation: conversation.toConversation(),
            message: message
        )
    }
}

private extension User {
    func toIntelocutor() -> RemoteMessageNotification.Conversation.Interlocutor {
        RemoteMessageNotification.Conversation.Interlocutor(
            id: id,
            firstName: firstName,
            lastName: lastName,
            fullName: fullName,
            email: email,
            schoolLevel: schoolLevel.rawValue,
            admin: admin,
            profilePictureFileName: UserUtils.ProfilePicture.getFileName(url: profilePictureUrl),
            state: state.rawValue,
            tester: tester
        )
    }
}

private extension RemoteMessageNotification.Conversation {
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

private extension RemoteMessageNotification.Conversation.Interlocutor {
    func toUser() -> User {
        User(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            schoolLevel: SchoolLevel(rawValue: schoolLevel) ?? .ged1,
            admin: admin,
            profilePictureUrl: UserUtils.ProfilePicture.url(fileName: profilePictureFileName),
            state: User.UserState(rawValue: state) ?? .active,
            tester: tester
        )
    }
}

