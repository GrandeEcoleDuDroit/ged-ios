
class DeleteUserAccountUseCase {
    private let userRepository: UserRepository
    private let authenticationRepository: AuthenticationRepository
    
    init(
        userRepository: UserRepository,
        authenticationRepository: AuthenticationRepository
    ) {
        self.userRepository = userRepository
        self.authenticationRepository = authenticationRepository
    }

    func execute(email: String, password: String) async throws {
        try await authenticationRepository.loginWithEmailAndPassword(email: email, password: password)
        try await userRepository.deleteCurrentUser()
        try await authenticationRepository.deleteAuthUser()
    }
}
