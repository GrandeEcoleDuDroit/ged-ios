import Combine

class CheckUserValidityUseCase {
    private let authenticationRepository: AuthenticationRepository
    private let userRepository: UserRepository
    private let networkMonitor: NetworkMonitor
    
    init(
        authenticationRepository: AuthenticationRepository,
        userRepository: UserRepository,
        networkMonitor: NetworkMonitor
    ) {
        self.authenticationRepository = authenticationRepository
        self.userRepository = userRepository
        self.networkMonitor = networkMonitor
    }
    
    func execute() async {
        await networkMonitor.connected.values.first { $0 }
        do {
            let isAuthenticated = try await authenticationRepository.isAuthenticated()
            if userRepository.currentUser == nil && isAuthenticated == true {
                authenticationRepository.logout()
            }
        } catch {
            if error as? AuthenticationError == .userDisabled {
                authenticationRepository.logout()
            }
        }
    }
}
