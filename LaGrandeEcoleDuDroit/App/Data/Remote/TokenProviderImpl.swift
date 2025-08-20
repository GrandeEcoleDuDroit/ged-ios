class TokenProviderImpl: TokenProvider {
    private let firebaseAuthenticationRepository: FirebaseAuthenticationRepository
    
    init(firebaseAuthenticationRepository: FirebaseAuthenticationRepository) {
        self.firebaseAuthenticationRepository = firebaseAuthenticationRepository
    }
    
    func getAuthIdToken() -> String? {
        firebaseAuthenticationRepository.authIdToken
    }
}
