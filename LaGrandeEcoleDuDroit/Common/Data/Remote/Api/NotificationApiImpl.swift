import Foundation

class NotificationApiImpl: NotificationApi {
    private let tag = String(describing: NotificationApiImpl.self)
    private let fcmApi: FcmApi
    
    init(fcmApi: FcmApi) {
        self.fcmApi = fcmApi
    }
    
    func sendNotification<T: Encodable>(recipientId: String, fcmMessage: FcmMessage<T>) async {
        do {
            let fcmJson = try JSONEncoder().encode(fcmMessage)
            guard let fcmMessageString = String(data: fcmJson, encoding: .utf8) else {
                throw NSError()
            }
            
            try await mapServerError(
                block: { try await fcmApi.sendNotification(recipientId: recipientId, fcmMessage: fcmMessageString) },
                tag: tag,
                message: "Failed to send notification"
            )
        } catch {
            e(tag, "Error sending notification", error)
        }
    }
}
