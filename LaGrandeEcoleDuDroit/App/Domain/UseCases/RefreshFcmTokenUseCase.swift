class RefreshFcmTokenUseCase {
    private let fcmTokenRepository: FcmTokenRepository
    private let networkMonitor: NetworkMonitor
    private let authenticationRepository: AuthenticationRepository
    private let userRepository: UserRepository
    
    init(
        fcmTokenRepository: FcmTokenRepository,
        networkMonitor: NetworkMonitor,
        authenticationRepository: AuthenticationRepository,
        userRepository: UserRepository
    ) {
        self.fcmTokenRepository = fcmTokenRepository
        self.networkMonitor = networkMonitor
        self.authenticationRepository = authenticationRepository
        self.userRepository = userRepository
    }
    
    func listen() {
        
    }
}
