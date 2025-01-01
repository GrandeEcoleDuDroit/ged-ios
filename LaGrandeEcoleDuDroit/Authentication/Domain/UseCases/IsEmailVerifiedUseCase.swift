class IsEmailVerifiedUseCase {
    private let authenticationRemoteRepository: AuthenticationRepository
    
    init(authenticationRemoteRepository: AuthenticationRepository) {
        self.authenticationRemoteRepository = authenticationRemoteRepository
    }
    
    func execute() async throws -> Bool {
        try await authenticationRemoteRepository.isEmailVerified()
    }
}
