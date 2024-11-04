class SendVerificationEmailUseCase {
    private let authenticationRemoteRepository: AuthenticationRemoteRepository
    
    init(authenticationRemoteRepository: AuthenticationRemoteRepository) {
        self.authenticationRemoteRepository = authenticationRemoteRepository
    }
    
    func execute() async throws {
        try await authenticationRemoteRepository.sendEmailVerification()
    }
}
