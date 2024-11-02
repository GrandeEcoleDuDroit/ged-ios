class IsAuthenticatedUseCase {
    private let firebaseAuthApi: FirebaseAuthApi = FirebaseAuthApiImpl()
    
    func execute() -> Bool {
        return firebaseAuthApi.isAuthenticated()
    }
}
