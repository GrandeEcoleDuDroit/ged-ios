import Combine
import os
import FirebaseAuth

class AuthenticationRemoteRepositoryImpl: AuthenticationRemoteRepository {
    private let firebaseAuthApi: FirebaseAuthApi = FirebaseAuthApiImpl()
    
    func register(email: String, password: String, completion: @escaping (Result<Void, AuthenticationError>) -> Void) {
        firebaseAuthApi.createUserWithEmail(email: email, password: password) { authResult, error in
            if let error = error {
                let errorCode = AuthErrorCode(rawValue: error._code)
                switch errorCode {
                case .emailAlreadyInUse:
                    completion(.failure(AuthenticationError.accountAlreadyExist))
                default:
                    completion(.failure(AuthenticationError.unknown))
                }
            } else {
                completion(.success(()))
            }
        }
    }
    
    func sendEmailVerification(completion: @escaping (Result<Void, AuthenticationError>) -> Void) {
        firebaseAuthApi.sendEmailVerification { error in
            if let error = error {
                let errorCode = AuthErrorCode(rawValue: error._code)
                switch errorCode {
                case .userNotFound:
                    completion(.failure(AuthenticationError.userNotFound))
                case .tooManyRequests:
                    completion(.failure(AuthenticationError.tooManyRequest))
                default:
                    completion(.failure(AuthenticationError.unknown))
                }
            } else {
                completion(.success(()))
            }
        }
    }
    
    func isEmailVerified(completion: @escaping (Bool) -> Void) {
        firebaseAuthApi.isEmailVerified(completion: completion)
    }
    
    func login(email: String, password: String, completion: @escaping (Result<Void, AuthenticationError>) -> Void) {
        firebaseAuthApi.signIn(email: email, password: password) { authResult, error in
            if let error = error {
                let errorCode = AuthErrorCode(rawValue: error._code)
                switch errorCode {
                case .wrongPassword:
                    completion(.failure(AuthenticationError.invalidCredentials))
                case .userNotFound:
                    completion(.failure(AuthenticationError.invalidCredentials))
                case .userDisabled:
                    completion(.failure(AuthenticationError.userDisabled))
                default:
                    completion(.failure(AuthenticationError.unknown))
                }
            } else {
                completion(.success(()))
            }
        }
    }
}
