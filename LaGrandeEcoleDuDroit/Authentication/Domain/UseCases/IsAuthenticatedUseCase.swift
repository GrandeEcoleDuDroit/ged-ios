class IsAuthenticatedUseCase {
    private let firebaseAuthApi: FirebaseAuthApi
    
    init(firebaseAuthApi: FirebaseAuthApi) {
        self.firebaseAuthApi = firebaseAuthApi
    }
    
    func execute() -> Bool {
        return firebaseAuthApi.isAuthenticated()
    }
}
