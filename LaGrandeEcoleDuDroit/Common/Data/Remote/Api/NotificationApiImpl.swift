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
            
            try await mapRetrofitError {
                try await fcmApi.sendNotification(recipientId: recipientId, fcmMessage: fcmMessageString)
            }
        } catch {
            e(tag, "Error sending notification: \(error.localizedDescription)", error)
        }
    }
}
