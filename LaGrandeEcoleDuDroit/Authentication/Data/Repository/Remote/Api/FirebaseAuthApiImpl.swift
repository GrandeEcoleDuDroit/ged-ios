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
}
