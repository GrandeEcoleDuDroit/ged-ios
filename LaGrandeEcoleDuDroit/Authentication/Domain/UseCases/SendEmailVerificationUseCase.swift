class SendEmailVerificationUseCase {
    private let authenticationRepository: AuthenticationRepository
    
    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }
    
    func execute() async throws {
        try await authenticationRepository.sendEmailVerification()
    }
}
