class LoginUseCase {
    private let authenticationRepository: AuthenticationRepository
    
    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }
    
    func execute(email: String, password: String) async throws {
        try await authenticationRepository.loginWithEmailAndPassword(email: email, password: password)
    }
}
