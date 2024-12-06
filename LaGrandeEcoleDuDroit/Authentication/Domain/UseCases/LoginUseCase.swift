class LoginUseCase {
    private let authenticationRemoteRepository: AuthenticationRemoteRepository
    
    init(authenticationRemoteRepository: AuthenticationRemoteRepository) {
        self.authenticationRemoteRepository = authenticationRemoteRepository
    }
    
    func execute(email: String, password: String) async throws -> String {
        try await authenticationRemoteRepository.login(email: email, password: password)
    }
}
