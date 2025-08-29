import Foundation
import Combine
import FirebaseAuth

private let tag = String(describing: FirebaseAuthenticationRepositoryImpl.self)

class FirebaseAuthenticationRepositoryImpl: FirebaseAuthenticationRepository {
    private let firebaseAuthApi: FirebaseAuthApi
    var authIdToken: String?

    init(firebaseAuthApi: FirebaseAuthApi) {
        self.firebaseAuthApi = firebaseAuthApi
        listenAuthIdTokenChanges()
    }
    
    func isAuthenticated() -> Bool {
        firebaseAuthApi.isAuthenticated()
    }
    
    func getAuthIdToken() async throws -> String? {
        if let authIdToken = authIdToken {
            authIdToken
        } else {
            try await firebaseAuthApi.getAuthToken()
        }
    }
    
    func loginWithEmailAndPassword(email: String, password: String) async throws {
        try await mapFirebaseException(
            block: { try await firebaseAuthApi.signIn(email: email, password: password) },
            tag: tag,
            message: "Failed to login with email and password",
            handleSpecificException: mapAuthError
        )
    }
    
    func registerWithEmailAndPassword(email: String, password: String) async throws -> String {
        try await mapFirebaseException(
            block: { try await firebaseAuthApi.signUp(email: email, password: password) },
            tag: tag,
            message: "Failed to register with email and password",
            handleSpecificException: mapAuthError
        )
    }
    
    func logout() {
        firebaseAuthApi.signOut()
    }
    
    func resetPassword(email: String) async throws {
        try await mapFirebaseException(
            block: { try await firebaseAuthApi.resetPassword(email: email) },
            tag: tag,
            message: "Failed to reset password",
            handleSpecificException: mapAuthError
        )
    }
    
    private func listenAuthIdTokenChanges() {
        firebaseAuthApi.listenTokenChanges { [weak self] token in
            self?.authIdToken = token
        }
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
