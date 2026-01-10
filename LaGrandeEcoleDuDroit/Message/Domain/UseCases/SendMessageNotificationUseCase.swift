class SendMessageNotificationUseCase {
    private let tag = String(describing: SendMessageNotificationUseCase.self)
    private let notificationApi: NotificationApi
    private let userRepository: UserRepository
    
    init(
        notificationApi: NotificationApi,
        userRepository: UserRepository
    ) {
        self.notificationApi = notificationApi
        self.userRepository = userRepository
    }
    
    func execute(notification: MessageNotification) async {
        guard let currentUser = userRepository.currentUser else {
            e(tag, "Error sending notification: Current user not found")
            return
        }
        
        let fcmMessage = notification.toRemote(currentUser: currentUser).toFcm()
        await notificationApi.sendNotification(
            userId: currentUser.id,
            recipientId: notification.conversation.interlocutor.id,
            fcmMessage: fcmMessage
        )
    }
}
