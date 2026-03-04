class LogoutUseCase {
    private let userRepository: UserRepository
    private let authenticationRepository: AuthenticationRepository
    private let fcmTokenRepository: FcmTokenRepository
    
    init(
        userRepository: UserRepository,
        authenticationRepository: AuthenticationRepository,
        fcmTokenRepository: FcmTokenRepository
    ) {
        self.userRepository = userRepository
        self.authenticationRepository = authenticationRepository
        self.fcmTokenRepository = fcmTokenRepository
    }
    
    func execute() async throws {
        guard let currentUser = userRepository.currentUser else {
            throw UserError.currentUserNotFound
        }
        
        try await fcmTokenRepository.deleteToken(userId: currentUser.id)
        authenticationRepository.logout()
    }
}
