import FirebaseMessaging
import Combine

class FcmManager: NSObject, MessagingDelegate {
    private let fcmTokenUseCase = MainInjection.shared.resolve(FcmTokenUseCase.self)
    private let userRepository = CommonInjection.shared.resolve(UserRepository.self)
    private var cancellable: AnyCancellable?
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken token: String?) {
        guard let token = token else { return }
        
        cancellable?.cancel()
        cancellable = userRepository.user
            .first()
            .sink { [weak self] user in
                Task {
                    await self?.fcmTokenUseCase.sendToken(fcmToken: FcmToken(userId: user.id, value: token))
                }
            }
    }
}
