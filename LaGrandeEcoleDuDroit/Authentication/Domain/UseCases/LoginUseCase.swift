class LoginUseCase {
    private let authenticationRemoteRepository: AuthenticationRemoteRepository = AuthenticationRemoteRepositoryImpl()
    
    func execute(email: String, password: String) async throws -> String {
        return try await authenticationRemoteRepository.login(email: email, password: password)
    }
}
