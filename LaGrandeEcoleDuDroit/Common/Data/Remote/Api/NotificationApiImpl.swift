import Foundation

class NotificationApiImpl: NotificationApi {
    private let tag = String(describing: NotificationApiImpl.self)
    private let fcmApi: FcmApi
    
    init(fcmApi: FcmApi) {
        self.fcmApi = fcmApi
    }
    
    func sendNotification<T: Encodable>(userId: String, recipientId: String, fcmMessage: FcmMessage<T>) async {
        do {
            let fcmJson = try JSONEncoder().encode(fcmMessage)
            let fcmMessageString = String(data: fcmJson, encoding: .utf8)!
            try await fcmApi.sendNotification(userId: userId, recipientId: recipientId, fcmMessage: fcmMessageString)
        } catch {
            e(tag, "Error sending notification to \(recipientId)", error)
        }
    }
}
