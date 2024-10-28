import Combine

class AuthenticationRemoteRepositoryImpl: AuthenticationRemoteRepository {
    private let firebaseAuthApi: FirebaseAuthApi = FirebaseAuthApiImpl()
    
    func register(email: String, password: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            self.firebaseAuthApi.createUserWithEmail(email: email, password: password) { authResult, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}
