import Combine

class IsUserAuthenticatedUseCase {
    private let authenticationRepository: AuthenticationRepository
    
    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }
    
    func execute() -> CurrentValueSubject<Bool, Never> {
        authenticationRepository.isAuthenticated
    }
}
