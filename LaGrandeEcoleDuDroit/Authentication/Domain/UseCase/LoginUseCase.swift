class LoginUseCase {
    private let authenticationRepository: AuthenticationRepository
    private let userRepository: UserRepository
    
    init(
        authenticationRepository: AuthenticationRepository,
        userRepository: UserRepository
    ) {
        self.authenticationRepository = authenticationRepository
        self.userRepository = userRepository
    }
    
    func execute(email: String, password: String) async throws {
        try await withTimeout(10) {
            try await self.authenticationRepository.loginWithEmailAndPassword(email: email, password: password)
            if let user = try await self.userRepository.getUserWithEmail(email: email) {
                self.userRepository.storeUser(user)
                self.authenticationRepository.setAuthenticated(true)
            } else {
                throw AuthenticationError.invalidCredentials
            }
        }
    }
}
