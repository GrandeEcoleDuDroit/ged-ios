import Combine

class RegisterUseCase {
    private let authenticationRemoteRepository: AuthenticationRemoteRepository = AuthenticationRemoteRepositoryImpl()
    
    func execute(email: String, password: String) async throws -> String {
        try await authenticationRemoteRepository.register(email: email, password: password)
    }
}
