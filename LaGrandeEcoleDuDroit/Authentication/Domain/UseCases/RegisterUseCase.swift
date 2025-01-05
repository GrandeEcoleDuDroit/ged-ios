class RegisterUseCase {
    private let authenticationRepository: AuthenticationRepository
    
    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }
    
    func execute(email: String, password: String) async throws -> String {
        try await authenticationRepository.register(email: email, password: password)
    }
}
