import FirebaseAuth

class FirebaseAuthApiImpl: FirebaseAuthApi {
    func createUserWithEmail(
        email: String,
        password: String,
        completion: @escaping (FirebaseAuth.AuthDataResult?, Error?) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            completion(authResult, error)
        }
    }
    
    func sendEmailVerification(
        completion: @escaping (Error?) -> Void
    ) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(
                NSError(
                    domain: "FirebaseAuthApi",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "User not connected"]
                )
            )
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
        
        currentUser.reload(completion: { error in
            if let error = error {
                print("Error while reloading user : \(error.localizedDescription)")
                completion(false)
                return
            }
            
            completion(currentUser.isEmailVerified)
        })
    }
}
