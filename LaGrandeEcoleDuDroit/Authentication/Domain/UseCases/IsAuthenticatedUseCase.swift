import Combine

class IsAuthenticatedUseCase {
    private let authenticationRemoteRepository: AuthenticationRepository
    
    init(authenticationRemoteRepository: AuthenticationRepository) {
        self.authenticationRemoteRepository = authenticationRemoteRepository
    }
    
    func execute() -> AnyPublisher<Bool, Never> {
        authenticationRemoteRepository.isAuthenticated
    }
}
