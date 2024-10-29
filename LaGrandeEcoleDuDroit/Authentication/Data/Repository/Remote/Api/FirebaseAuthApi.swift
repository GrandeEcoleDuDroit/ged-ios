import FirebaseAuth

protocol FirebaseAuthApi {
    func createUserWithEmail(
        email: String,
        password: String,
        completion: @escaping (AuthDataResult?, Error?) -> Void
    )
    
    func sendEmailVerification(completion: @escaping (Error?) -> Void)
    
    func isEmailVerified(completion: @escaping (Bool) -> Void)
}
