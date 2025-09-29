import Combine

class ListenAuthenticationStateUseCase {
    private let authenticationRepository: AuthenticationRepository
    private let userRepository: UserRepository
    private var cancellables: Set<AnyCancellable> = []
    
    private let authenticatedPublisher = CurrentValueSubject<Bool?, Never>(nil)
    var authenticated: AnyPublisher<Bool, Never> {
        authenticatedPublisher
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    var isAuthenticated: Bool {
        authenticatedPublisher.value ?? false
    }
    
    init(
        authenticationRepository: AuthenticationRepository,
        userRepository: UserRepository
    ) {
        self.authenticationRepository = authenticationRepository
        self.userRepository = userRepository
        
        initAuthentication()
    }
    
    private func initAuthentication() {
        if userRepository.getCurrentUser() == nil {
            authenticationRepository.logout()
        }
        
        authenticationRepository.getAuthenticationState().sink { [weak self] isAuthenticated in
            self?.authenticatedPublisher.send(isAuthenticated)
        }.store(in: &cancellables)
    }
}
