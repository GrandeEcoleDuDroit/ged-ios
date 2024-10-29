import Combine
import os
class AuthenticationRemoteRepositoryImpl: AuthenticationRemoteRepository {
    private let firebaseAuthApi: FirebaseAuthApi = FirebaseAuthApiImpl()
    private let logger = Logger(subsystem: "com.upsaclay.gedoise", category: "debug")
    
    func register(email: String, password: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            self.firebaseAuthApi.createUserWithEmail(email: email, password: password) { authResult, error in
                if let error = error {
                    self.logger.log("Failed to register user with email: \(email). Error: \(error.localizedDescription)")
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func sendEmailVerification(completion: @escaping (Result<Void, Error>) -> Void) {
        firebaseAuthApi.sendEmailVerification { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func isEmailVerified(completion: @escaping (Bool) -> Void) {
        firebaseAuthApi.isEmailVerified(completion: completion)
    }
}
