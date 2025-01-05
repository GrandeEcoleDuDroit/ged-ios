class IsEmailVerifiedUseCase {
    private let authenticationRepository: AuthenticationRepository
    
    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }
    
    func execute() async throws -> Bool {
        try await authenticationRepository.isEmailVerified()
    }
}
