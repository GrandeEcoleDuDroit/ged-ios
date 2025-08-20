class MockNotificationApi: NotificationApi {
    func sendNotification<T>(recipientId: String, fcmMessage: FcmMessage<T>) async where T : Encodable {}
}
