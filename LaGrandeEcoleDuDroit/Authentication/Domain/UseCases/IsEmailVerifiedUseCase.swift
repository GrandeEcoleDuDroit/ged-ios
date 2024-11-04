class IsEmailVerifiedUseCase {
    private let authenticationRemoteRepository: AuthenticationRemoteRepository
    
    init(authenticationRemoteRepository: AuthenticationRemoteRepository) {
        self.authenticationRemoteRepository = authenticationRemoteRepository
    }
    
    func execute() async throws -> Bool {
        try await authenticationRemoteRepository.isEmailVerified()
    }
}
