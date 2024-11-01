import FirebaseAuth
import os

class FirebaseAuthApiImpl: FirebaseAuthApi {
    private let logger = Logger(subsystem: "com.upsaclay.gedoise", category: "debug")
    
    func createUserWithEmail(email: String, password: String) async throws -> FirebaseAuth.AuthDataResult? {
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.logger.error("FirebaseAuth create user error: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: authResult)
                }
            }
        }
    }
    
    func sendEmailVerification() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            guard let currentUser = Auth.auth().currentUser else {
                self.logger.error("FirebaseAuth send email verification error: User not connected")
                continuation.resume(throwing: AuthenticationError.userNotConnected)
                return
            }
            
            currentUser.sendEmailVerification { error in
                if let error = error {
                    self.logger.error("FirebaseAuth send email verification error: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func isEmailVerified() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            guard let currentUser = Auth.auth().currentUser else {
                self.logger.error("FirebaseAuth is email verified error: User not connected")
                continuation.resume(throwing: AuthenticationError.userNotConnected)
                return
            }
            
            currentUser.reload { error in
                if let error = error {
                    self.logger.error("Error while reloading user : \(error.localizedDescription)")
                    continuation.resume(returning: false)
                } else {
                    continuation.resume(returning: currentUser.isEmailVerified)
                }
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.logger.error("FirebaseAuth sign in user error: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
}
