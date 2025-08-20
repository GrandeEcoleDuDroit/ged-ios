protocol NotificationApi {
    func sendNotification<T: Encodable>(recipientId: String, fcmMessage: FcmMessage<T>) async
}
