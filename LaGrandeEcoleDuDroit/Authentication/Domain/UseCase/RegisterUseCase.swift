import Combine

class RegisterUseCase {
    private let authenticationRemoteRepository: AuthenticationRemoteRepository = AuthenticationRemoteRepositoryImpl()
    
    func execute(email: String, password: String) -> AnyPublisher<Void, Error> {
        return authenticationRemoteRepository.register(email: email, password: password)
    }
}
