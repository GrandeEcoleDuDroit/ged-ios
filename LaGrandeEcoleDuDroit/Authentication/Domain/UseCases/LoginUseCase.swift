class LoginUseCase {
    private let authenticationRemoteRepository: AuthenticationRepository
    
    init(authenticationRemoteRepository: AuthenticationRepository) {
        self.authenticationRemoteRepository = authenticationRemoteRepository
    }
    
    func execute(email: String, password: String) async throws -> String {
        try await authenticationRemoteRepository.login(email: email, password: password)
    }
}
