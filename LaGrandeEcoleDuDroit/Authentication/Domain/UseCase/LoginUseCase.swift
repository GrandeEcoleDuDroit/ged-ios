class LoginUseCase {
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
    
    func execute(email: String, password: String) async throws {
        guard networkMonitor.isConnected else {
            throw NetworkError.noInternetConnection
        }
        
        try await withTimeout(10000) {
            try await self.authenticationRepository.loginWithEmailAndPassword(email: email, password: password)
            if let user = try await self.userRepository.getUserWithEmail(email: email) {
                self.userRepository.storeUser(user)
                self.authenticationRepository.setAuthenticated(true)
            } else {
                throw AuthenticationError.invalidCredentials
            }
        }
    }
}
