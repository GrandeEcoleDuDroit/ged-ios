import Foundation
import FirebaseMessaging
import Combine

class FcmTokenUseCase {
    private let userRepository: UserRepository
    private let fcmTokenRepository: FcmTokenRepository
    private let networkMonitor: NetworkMonitor
    private let listenAuthenticationStateUseCase: ListenAuthenticationStateUseCase
    
    private var cancellables = Set<AnyCancellable>()
    private let tag = String(describing: FcmTokenUseCase.self)
    
    init(
        userRepository: UserRepository,
        fcmTokenRepository: FcmTokenRepository,
        networkMonitor: NetworkMonitor,
        listenAuthenticationStateUseCase: ListenAuthenticationStateUseCase
    ) {
        self.userRepository = userRepository
        self.fcmTokenRepository = fcmTokenRepository
        self.networkMonitor = networkMonitor
        self.listenAuthenticationStateUseCase = listenAuthenticationStateUseCase
    }
    
    func listen() {
        Publishers.CombineLatest(
            listenAuthenticationStateUseCase.authenticated,
            networkMonitor.connected.filter { $0 }
        ).map { authenticated, _ in
            authenticated
        }.sink { [weak self] authenticated in
            if authenticated {
                self?.sendTokenIfNecessary()
            } else {
                self?.removeToken()
            }
        }.store(in: &cancellables)
    }
    
    private func sendTokenIfNecessary() {
        Task {
            guard let fcmToken = await self.fcmTokenRepository.getUnsetToken() else { return }
            guard let userId = fcmToken.userId ?? self.userRepository.currentUser?.id else { return }
            await self.sendToken(fcmToken: fcmToken.with(userId: userId))
        }
    }
    
    func sendToken(fcmToken: FcmToken) async {
        do {
            try await fcmTokenRepository.sendFcmToken(token: fcmToken)
            try await fcmTokenRepository.removeUnsetToken()
        } catch {
            print("Error sending Fcm token: \(error)")
            try? await fcmTokenRepository.storeUnsetToken(token: fcmToken)
        }
    }
    
    private func removeToken() {
        Task {
            do {
                try await fcmTokenRepository.removeUnsetToken()
                try await Messaging.messaging().deleteToken()
                let token = try await Messaging.messaging().token()
                try await fcmTokenRepository.storeUnsetToken(token: FcmToken(userId: nil, value: token))
            } catch {
                e(tag, "Error removing Fcm token", error)
            }
        }
    }
}
