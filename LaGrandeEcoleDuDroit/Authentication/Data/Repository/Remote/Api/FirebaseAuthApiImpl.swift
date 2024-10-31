import FirebaseAuth
import os

class FirebaseAuthApiImpl: FirebaseAuthApi {
    private let logger = Logger(subsystem: "com.upsaclay.gedoise", category: "debug")
    
    func createUserWithEmail(
        email: String,
        password: String,
        completion: @escaping (FirebaseAuth.AuthDataResult?, Error?) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.logger.error("FirebaseAuth create user error: \(error.localizedDescription)")
            }
            completion(authResult, error)
        }
    }
    
    func sendEmailVerification(
        completion: @escaping (Error?) -> Void
    ) {
        guard let currentUser = Auth.auth().currentUser else {
            self.logger.error("FirebaseAuth send email verification error: User not connected")
            completion(AuthenticationError.userNotConnected)
            return
        }
        
        currentUser.sendEmailVerification { error in
            completion(error)
        }
    }
    
    func isEmailVerified(completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        currentUser.reload(
            completion: { error in
                if let error = error {
                    self.logger.error("Error while reloading user : \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                completion(false)
            })
    }
    
    func signIn(
        email: String,
        password: String,
        completion: @escaping (FirebaseAuth.AuthDataResult?, Error?) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.logger.error("FirebaseAuth sign in user error: \(error.localizedDescription)")
            }
            completion(authResult, error)
        }
    }
}
