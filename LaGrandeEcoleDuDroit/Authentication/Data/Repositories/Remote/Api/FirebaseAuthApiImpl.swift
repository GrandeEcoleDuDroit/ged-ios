import FirebaseAuth
import os

class FirebaseAuthApiImpl: FirebaseAuthApi {
    func createUserWithEmail(email: String, password: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func sendEmailVerification() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            guard let currentUser = Auth.auth().currentUser else {
                continuation.resume(throwing: AuthenticationError.userNotConnected)
                return
            }
            
            currentUser.sendEmailVerification { error in
                if let error = error {
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
                continuation.resume(throwing: AuthenticationError.userNotConnected)
                return
            }
            
            currentUser.reload { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: currentUser.isEmailVerified)
                }
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if authResult != nil {
                    continuation.resume()
                } else if let error = error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func signOut() async throws {
        try Auth.auth().signOut()
    }
    
    func resetPassword(email: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if error != nil {
                    continuation.resume(throwing: error!)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func isAuthenticated() -> Bool {
        Auth.auth().currentUser != nil
    }
}
