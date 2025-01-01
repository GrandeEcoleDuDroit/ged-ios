import Combine
import os
import FirebaseAuth

class AuthenticationRepositoryImpl: AuthenticationRepository {
    private let firebaseAuthApi: FirebaseAuthApi
    @Published private var _isAuthenticated: Bool = false
    var isAuthenticated: AnyPublisher<Bool, Never> {
        $_isAuthenticated.eraseToAnyPublisher()
    }
    
    init(firebaseAuthApi: FirebaseAuthApi) {
        self.firebaseAuthApi = firebaseAuthApi
        _isAuthenticated = firebaseAuthApi.isAuthenticated()
    }
    
    func register(email: String, password: String) async throws -> String {
        do {
            let authResult = try await firebaseAuthApi.createUserWithEmail(email: email, password: password)
            return authResult.user.uid
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
    
    func sendEmailVerification() async throws {
        try await firebaseAuthApi.sendEmailVerification()
    }
    
    func isEmailVerified() async throws -> Bool {
        try await firebaseAuthApi.isEmailVerified()
    }
    
    func login(email: String, password: String) async throws -> String {
        do {
            let authDataResult = try await firebaseAuthApi.signIn(email: email, password: password)
            _isAuthenticated = true
            return authDataResult.user.uid
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
    
    func logout() throws {
        do {
            try firebaseAuthApi.signOut()
            _isAuthenticated = false
        } catch {
            throw AuthenticationError.unknown
        }
    }
}
