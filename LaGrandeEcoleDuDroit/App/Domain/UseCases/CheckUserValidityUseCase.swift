import Combine

class CheckUserValidityUseCase {
    private let authenticationRepository: AuthenticationRepository
    private let userRepository: UserRepository
    private let tag = String(describing: CheckUserValidityUseCase.self)
    
    init(
        authenticationRepository: AuthenticationRepository,
        userRepository: UserRepository
    ) {
        self.authenticationRepository = authenticationRepository
        self.userRepository = userRepository
    }
    
    func execute() async {
        let isAuthenticated = await authenticationRepository.authenticated.values.first { $0 }
        let currentUser = userRepository.getCurrentUser()
        if currentUser == nil && isAuthenticated == true {
            authenticationRepository.logout()
        }
    }
}
