class RegisterUseCase {
    private let authenticationRemoteRepository: AuthenticationRemoteRepository
    
    init(authenticationRemoteRepository: AuthenticationRemoteRepository) {
        self.authenticationRemoteRepository = authenticationRemoteRepository
    }
    
    func execute(email: String, password: String) async throws -> String {
        try await authenticationRemoteRepository.register(email: email, password: password)
    }
}
