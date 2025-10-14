class TokenProviderImpl: TokenProvider {
    private let authenticationRepository: AuthenticationRepository
    
    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }
    
    func getAuthToken() async -> String? {
        try? await authenticationRepository.getToken()
    }
}
