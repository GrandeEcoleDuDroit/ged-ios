import Combine

class IsAuthenticatedUseCase {
    private let authenticationRepository: AuthenticationRepository
    
    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }
    
    func execute() -> AnyPublisher<Bool, Never> {
        authenticationRepository.isAuthenticated.eraseToAnyPublisher()
    }
}
