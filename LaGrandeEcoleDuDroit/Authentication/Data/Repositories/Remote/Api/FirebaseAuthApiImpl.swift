import FirebaseAuth
import os

class FirebaseAuthApiImpl: FirebaseAuthApi {
    func isAuthenticated() -> Bool {
        Auth.auth().currentUser != nil
    }
    
    func getAuthToken() async throws -> String? {
        try await withCheckedThrowingContinuation { continuation in
            guard let user = Auth.auth().currentUser else {
                continuation.resume(returning: nil)
                return
            }
            
            user.getIDTokenResult() { result, error in
                if let result = result, result.expirationDate > Date() {
                    continuation.resume(returning: result.token)
                } else {
                    user.getIDTokenResult(forcingRefresh: true) { refreshedResult, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                            return
                        }
                        
                        if let refreshedResult = refreshedResult {
                            continuation.resume(returning: refreshedResult.token)
                        } else {
                            continuation.resume(returning: nil)
                        }
                    }
                }
            }
        }
    }
        
    func signIn(email: String, password: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if authResult != nil {
                    continuation.resume()
                } else if let error = error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func signUp(email: String, password: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: (authResult?.user.uid)!)
                }
            }
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
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
    
    func listenTokenChanges(completion: @escaping (String?) -> Void) {
        Auth.auth().addIDTokenDidChangeListener { auth, user in
            guard let user = user else {
                completion(nil)
                return
            }
            
            user.getIDTokenResult(forcingRefresh: false) { result, error in
                if let result = result, result.expirationDate > Date() {
                    completion(result.token)
                } else {
                    user.getIDTokenResult(forcingRefresh: true) { refreshedResult, error in
                        completion(refreshedResult?.token)
                    }
                }
            }

        }
    }
}
