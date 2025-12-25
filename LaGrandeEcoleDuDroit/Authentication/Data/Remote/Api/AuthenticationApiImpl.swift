import FirebaseAuth
import Combine

class AuthenticationApiImpl: AuthenticationApi {
    private let firebaseAuth = Auth.auth()
    private let tag = String(describing: AuthenticationApiImpl.self)

    func isAuthenticated() async throws -> Bool {
        try await mapFirebaseError(
            block: { try await firebaseAuth.currentUser?.getIDTokenResult(forcingRefresh: true) != nil },
            tag: tag,
            message: "Failed to check if user is authenticated",
            handleSpecificException: mapAuthError
        )
    }
    
    func listenToken() -> AnyPublisher<String?, Never> {
        let authTokenSubject = PassthroughSubject<String?, Never>()
        
        firebaseAuth.addIDTokenDidChangeListener { auth, user in
            guard let user else {
                authTokenSubject.send(nil)
                return
            }
            
            user.getIDTokenResult(forcingRefresh: false) { result, error in
                if let result, result.expirationDate > Date() {
                    authTokenSubject.send(result.token)
                } else {
                    user.getIDTokenResult(forcingRefresh: true) { refreshedResult, error in
                        authTokenSubject.send(refreshedResult?.token)
                    }
                }
            }
        }
        
        return authTokenSubject.eraseToAnyPublisher()
    }
    
    func getToken() async throws -> String? {
        try await firebaseAuth.currentUser?.getIDTokenResult().token
    }
    
    func login(email: String, password: String) async throws -> String {
        try await mapFirebaseError(
            block: {
                let result = try await firebaseAuth.signIn(withEmail: email, password: password)
                return result.user.uid
            },
            tag: tag,
            message: "Failed to login with email and password",
            handleSpecificException: mapAuthError
        )
    }
    
    func register(email: String, password: String) async throws -> String {
        try await mapFirebaseError(
            block: { try await firebaseAuth.createUser(withEmail: email, password: password) },
            tag: tag,
            message: "Failed to register with email and password",
            handleSpecificException: mapAuthError
        ).user.uid
    }
    
    func logout() {
        try? firebaseAuth.signOut()
    }
    
    func resetPassword(email: String) async throws {
        try await mapFirebaseError(
            block: { try await firebaseAuth.sendPasswordReset(withEmail: email) },
            tag: tag,
            message: "Failed to reset password",
            handleSpecificException: mapAuthError
        )
    }
    
    private func mapAuthError(error: Error) -> Error {
        let nsError = error as NSError
        return if let authErrorCode = AuthErrorCode(rawValue: nsError.code) {
            switch authErrorCode {
                case .wrongPassword, .userNotFound, .invalidCredential: AuthenticationError.invalidCredentials
                case .emailAlreadyInUse: NetworkError.dupplicateData
                case .userDisabled: AuthenticationError.userDisabled
                case .networkError: NetworkError.noInternetConnection
                case .tooManyRequests: NetworkError.tooManyRequests
                default: error
            }
        } else {
            error
        }
    }
}
