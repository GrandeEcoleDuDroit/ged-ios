import FirebaseAuth
import Combine

class AuthenticationApiImpl: AuthenticationApi {
    private let firebaseAuth = Auth.auth()
    private let tag = String(describing: AuthenticationApiImpl.self)

    func isAuthenticated() async throws -> Bool {
        do {
            return try await firebaseAuth.currentUser?.getIDTokenResult(forcingRefresh: true) != nil
        } catch {
            e(tag, "Failed to check if user is authenticated")
            throw mapError(error)
        }
    }
    
    func listenAuthToken() -> AnyPublisher<AuthToken?, Never> {
        let authTokenSubject = PassthroughSubject<AuthToken?, Never>()
        
        firebaseAuth.addIDTokenDidChangeListener { auth, user in
            guard let user else {
                authTokenSubject.send(nil)
                return
            }
            
            user.getIDTokenResult { result, error in
                if let result {
                    authTokenSubject.send(AuthToken(token: result.token, expirationDate: result.expirationDate))
                } else {
                    authTokenSubject.send(nil)
                }
            }
        }
        
        return authTokenSubject.eraseToAnyPublisher()
    }
    
    func getAuthToken() async throws -> AuthToken? {
        if let result = try await firebaseAuth.currentUser?.getIDTokenResult() {
            return AuthToken(token: result.token, expirationDate: result.expirationDate)
        } else {
            return nil
        }
    }
    
    func login(email: String, password: String) async throws -> String {
        do {
            return try await firebaseAuth.signIn(withEmail: email, password: password).user.uid
        } catch {
            e(tag, "Failed to login with email and password")
            throw mapError(error)
        }
    }
    
    func register(email: String, password: String) async throws -> String {
        do {
            return try await firebaseAuth.createUser(withEmail: email, password: password).user.uid
        } catch {
            e(tag, "Failed to register with email and password")
            throw mapError(error)
        }
    }
    
    func logout() {
        try? firebaseAuth.signOut()
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await firebaseAuth.sendPasswordReset(withEmail: email)
        } catch {
            e(tag, "Failed to reset password")
            throw mapError(error)
        }
    }
    
    private func mapError(_ error: Error) -> Error {
        if let authErrorCode = AuthErrorCode(rawValue: (error as NSError).code) {
            switch authErrorCode {
                case .wrongPassword, .userNotFound, .invalidCredential: AuthenticationError.invalidCredentials
                case .emailAlreadyInUse: AuthenticationError.emailAlreadyInUse
                case .userDisabled: AuthenticationError.userDisabled
                case .networkError: NetworkError.any
                case .tooManyRequests: NetworkError.tooManyRequests
                default: error
            }
        } else {
            mapFirebaseError(error)
        }
    }
}
