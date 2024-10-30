class LoginUseCase {
    private let authenticationRemoteRepository: AuthenticationRemoteRepository = AuthenticationRemoteRepositoryImpl()
    
    func execute(email: String, password: String, completion: @escaping (Result<Void, AuthenticationError>) -> Void) {
        return authenticationRemoteRepository.login(email: email, password: password, completion: completion)
    }
}
