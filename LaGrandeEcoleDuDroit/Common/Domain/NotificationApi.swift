protocol NotificationApi {
    func sendNotification<T: Encodable>(userId: String, recipientId: String, fcmMessage: FcmMessage<T>) async
}
