protocol FirebaseAuthenticationRepository {
    func loginWithEmailAndPassword(email: String, password: String) async throws
    
    func registerWithEmailAndPassword(email: String, password: String) async throws
    
    func logout() async throws
    
    func sendEmailVerification() async throws
    
    func isEmailVerified() async throws -> Bool
}
