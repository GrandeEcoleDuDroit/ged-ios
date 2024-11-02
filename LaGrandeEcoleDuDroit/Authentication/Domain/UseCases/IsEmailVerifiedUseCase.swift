class IsEmailVerifiedUseCase {
    private let authenticationRemoteRepository: AuthenticationRemoteRepository = AuthenticationRemoteRepositoryImpl()
    
    func execute() async throws -> Bool {
        try await authenticationRemoteRepository.isEmailVerified()
    }
}
