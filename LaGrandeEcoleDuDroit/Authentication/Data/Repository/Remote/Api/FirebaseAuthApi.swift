import FirebaseAuth

protocol FirebaseAuthApi {
    func createUserWithEmail(
        email: String,
        password: String,
        completion: @escaping (AuthDataResult?, Error?) -> Void
    )
    
    func sendEmailVerification(completion: @escaping (Error?) -> Void)
    
    func isEmailVerified(completion: @escaping (Bool) -> Void)
    
    func signIn(email: String, password: String, completion: @escaping (FirebaseAuth.AuthDataResult?, Error?) -> Void)
}
