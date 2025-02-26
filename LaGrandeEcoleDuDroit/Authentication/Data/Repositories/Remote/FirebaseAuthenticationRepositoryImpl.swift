import Foundation
import FirebaseAuth

class FirebaseAuthenticationRepositoryImpl: FirebaseAuthenticationRepository {
    private let firebaseAuthApi: FirebaseAuthApi
    
    init(firebaseAuthApi: FirebaseAuthApi) {
        self.firebaseAuthApi = firebaseAuthApi
    }
    
    func loginWithEmailAndPassword(email: String, password: String) async throws {
        do {
            try await firebaseAuthApi.signIn(email: email, password: password)
        } catch let error as NSError {
            if let authErrorCode = AuthErrorCode(rawValue: error.code) {
                switch authErrorCode {
                    case .wrongPassword, .userNotFound, .invalidCredential:
                        throw AuthenticationError.invalidCredentials
                    case .userDisabled:
                        throw AuthenticationError.userDisabled
                    default:
                        throw AuthenticationError.unknown
                }
            }
            else {
                throw AuthenticationError.unknown
            }
        }
    }
    
    func registerWithEmailAndPassword(email: String, password: String) async throws {
        do {
            try await firebaseAuthApi.createUserWithEmail(email: email, password: password)
        } catch let error as NSError {
            if let authErrorCode = AuthErrorCode(rawValue: error.code) {
                switch authErrorCode {
                    case .emailAlreadyInUse:
                        throw AuthenticationError.accountAlreadyExist
                    default:
                        throw AuthenticationError.unknown
                }
            } else {
                throw AuthenticationError.unknown
            }
        }
    }
    
    func logout() async throws {
        do {
            try await firebaseAuthApi.signOut()
        } catch {
            throw AuthenticationError.unknown
        }
    }
    
    func sendEmailVerification() async throws {
        try await firebaseAuthApi.sendEmailVerification()
    }
    
    func isEmailVerified() async throws -> Bool {
        try await firebaseAuthApi.isEmailVerified()
    }
}
