class SetUserAuthenticatedUseCase {
    private let authenticationRepository: AuthenticationRepository

    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }
    
    func execute(_ isAuthenticated: Bool) async {
        await authenticationRepository.setAuthenticated(isAuthenticated)
    }
}
