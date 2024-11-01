class SendVerificationEmailUseCase {
    private let authenticationRemoteRepository: AuthenticationRemoteRepository = AuthenticationRemoteRepositoryImpl()
    
    func execute() async throws {
        try await authenticationRemoteRepository.sendEmailVerification()
    }
}
