import FirebaseMessaging
import Combine

class FcmManager: NSObject, MessagingDelegate {
    private let fcmTokenUseCase = AppInjector.shared.resolve(FcmTokenUseCase.self)
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken token: String?) {
        if let token {
            Task { await fcmTokenUseCase.handleReceivedToken(token: token) }
        }
    }
}
