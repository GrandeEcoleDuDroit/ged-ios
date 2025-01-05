class LoginUseCase {
    private let authenticationRepository: AuthenticationRepository
    
    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }
    
    func execute(email: String, password: String) async throws -> String {
        try await authenticationRepository.login(email: email, password: password)
    }
}
