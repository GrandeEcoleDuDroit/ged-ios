class TokenProviderImpl: TokenProvider {
    private let firebaseAuthenticationRepository: FirebaseAuthenticationRepository
    
    init(firebaseAuthenticationRepository: FirebaseAuthenticationRepository) {
        self.firebaseAuthenticationRepository = firebaseAuthenticationRepository
    }
    
    func getAuthIdToken() async -> String? {
        try? await firebaseAuthenticationRepository.getAuthIdToken()
    }
}
