class LoginUseCase {
    private let authenticationRepository: AuthenticationRepository
    
    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }
    
    func execute(email: String, password: String) async throws {
        let userId = try await withTimeout(10) { [weak self] in
            try await self?.authenticationRepository.loginWithEmailAndPassword(email: email, password: password)
        }
            
        if let userId {
            authenticationRepository.storeAuthenticationState(.authenticated(userId: userId))
        } else {
            throw AuthenticationError.authUserNotFound
        }
    }
}
