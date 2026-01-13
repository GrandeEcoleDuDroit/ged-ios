class MockNotificationApi: NotificationApi {
    func sendNotification<T>(userId: String,recipientId: String,fcmMessage: FcmMessage<T>) async where T : Encodable {}
}
