import FirebaseAuth
import Combine

class AuthenticationApiImpl: AuthenticationApi {
    private let firebaseAuth = Auth.auth()
    private let tag = String(describing: AuthenticationApiImpl.self)
    
    func listenAuthenticationState() -> AnyPublisher<Bool, Never> {
        Deferred { [weak self] in
           let subject = PassthroughSubject<Bool, Never>()
            
           let listener = self?.firebaseAuth.addStateDidChangeListener { auth, _ in
               subject.send(auth.currentUser != nil)
           }
            
           return subject.handleEvents(receiveCancel: { [weak self] in
               if let listener {
                   self?.firebaseAuth.removeStateDidChangeListener(listener)
               }
           })
       }
       .eraseToAnyPublisher()
    }
    
    func listenAuthTokenState() -> AnyPublisher<AuthTokenState, Never> {
        Deferred { [weak self] in
            let subject = PassthroughSubject<AuthTokenState, Never>()
            
            let listener = self?.firebaseAuth.addIDTokenDidChangeListener { auth, _ in
                guard let user = auth.currentUser else {
                    subject.send(.unauthenticated)
                    return
                }
                
                user.getIDTokenResult(forcingRefresh: true) { result, error in
                    if let error {
                        subject.send(.error(error))
                        return
                    }
                    
                    if let token = result?.token {
                        subject.send(.valid(token))
                    } else {
                        subject.send(.error())
                    }
                }
            }
            
            return subject.handleEvents(receiveCancel: { [weak self] in
                if let listener {
                    self?.firebaseAuth.removeIDTokenDidChangeListener(listener)
                }
            })
        }.eraseToAnyPublisher()
    }
    
    
    func getAuthToken() async throws -> String? {
        try await firebaseAuth.currentUser?.getIDTokenResult().token
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
