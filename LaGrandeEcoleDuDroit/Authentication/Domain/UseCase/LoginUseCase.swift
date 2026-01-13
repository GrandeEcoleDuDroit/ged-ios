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
        let uid = try await withTimeout(10) { [weak self] in
            try await self?.authenticationRepository.loginWithEmailAndPassword(email: email, password: password)
        }
            
        if let uid, let user = try await userRepository.getUser(userId: uid) {
            userRepository.storeUser(user)
            authenticationRepository.setAuthenticated(true)
        } else {
            throw AuthenticationError.authUserNotFound
        }
    }
}
