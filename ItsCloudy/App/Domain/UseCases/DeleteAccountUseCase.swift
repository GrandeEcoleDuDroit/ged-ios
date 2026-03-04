class DeleteAccountUseCase {
    private let userRepository: UserRepository
    private let authenticationRepository: AuthenticationRepository
    
    init(
        userRepository: UserRepository,
        authenticationRepository: AuthenticationRepository
    ) {
        self.userRepository = userRepository
        self.authenticationRepository = authenticationRepository
    }

    func execute(user: User, password: String) async throws {
        try await authenticationRepository.loginWithEmailAndPassword(email: user.email, password: password)
        try await userRepository.deleteUser(user: user)
        authenticationRepository.storeAuthenticationState(.unauthenticated)
    }
}
