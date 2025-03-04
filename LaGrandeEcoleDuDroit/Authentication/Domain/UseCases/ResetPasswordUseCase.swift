class ResetPasswordUseCase {
    private let authenticationRepository: AuthenticationRepository
    
    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }
    
    func execute(email: String) async throws {
        try await authenticationRepository.resetPassword(email: email)
    }
}
