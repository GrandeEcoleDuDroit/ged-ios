class MockSendMessageNotificationUseCase: SendMessageNotificationUseCase {
    
    override init(
        notificationApi: NotificationApi = MockNotificationApi(),
        userRepository: UserRepository = MockUserRepository()
    ) {
        super.init(notificationApi: notificationApi, userRepository: userRepository)
    }
    
    override func execute(notification: MessageNotification) async {}
}
