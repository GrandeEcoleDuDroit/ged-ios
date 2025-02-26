class RegisterUseCase {
    private let authenticationRepository: AuthenticationRepository
    
    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }
    
    func execute(email: String, password: String) async throws {
        try await authenticationRepository.registerWithEmailAndPassword(email: email, password: password)
    }
}
