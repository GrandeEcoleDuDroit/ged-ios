import Foundation
import FirebaseMessaging
import Combine

class FcmTokenUseCase {
    private let userRepository: UserRepository
    private let fcmTokenRepository: FcmTokenRepository
    
    private let tag = String(describing: FcmTokenUseCase.self)
    
    init(
        userRepository: UserRepository,
        fcmTokenRepository: FcmTokenRepository
    ) {
        self.userRepository = userRepository
        self.fcmTokenRepository = fcmTokenRepository
    }
    
    func sendUnsentToken() async {
        guard let currentUserId = userRepository.currentUser?.id else { return }
        let fcmToken = fcmTokenRepository.getFcmToken()
        if let fcmToken {
            if !fcmToken.sent {
                await addFcmToken(userId: currentUserId, fcmToken: fcmToken)
            }
        } else {
            if let token = try? await Messaging.messaging().token() {
                await addFcmToken(userId: currentUserId, fcmToken: FcmToken(token: token, sent: false))
            }
        }
    }
    
    func handleReceivedToken(token: String) async {
        guard token != fcmTokenRepository.getFcmToken()?.token else {
            return
        }
        
        let fcmToken = FcmToken(token: token, sent: false)
        try? fcmTokenRepository.storeFcmToken(fcmToken: fcmToken)
        if let currentUserId = userRepository.currentUser?.id {
            await addFcmToken(userId: currentUserId, fcmToken: fcmToken)
        }
    }
    
    private func addFcmToken(userId: String, fcmToken: FcmToken) async {
        do {
            try await fcmTokenRepository.sendFcmToken(userId: userId, token: fcmToken.token)
            try? fcmTokenRepository.storeFcmToken(fcmToken: fcmToken.copy { $0.sent = true })
        } catch {
            e(tag, "Error adding fcm token: \(error)")
            try? fcmTokenRepository.storeFcmToken(fcmToken: fcmToken.copy { $0.sent = false })
        }
    }
}
