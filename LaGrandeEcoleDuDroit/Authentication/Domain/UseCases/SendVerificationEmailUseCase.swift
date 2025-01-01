class SendVerificationEmailUseCase {
    private let authenticationRemoteRepository: AuthenticationRepository
    
    init(authenticationRemoteRepository: AuthenticationRepository) {
        self.authenticationRemoteRepository = authenticationRemoteRepository
    }
    
    func execute() async throws {
        try await authenticationRemoteRepository.sendEmailVerification()
    }
}
