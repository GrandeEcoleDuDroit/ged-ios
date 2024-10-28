import FirebaseAuth

protocol FirebaseAuthApi {
    func createUserWithEmail(
        email: String,
        password: String,
        completion: @escaping (AuthDataResult?, Error?) -> Void
    )
}
