import FirebaseAuth

protocol FirebaseAuthApi {
    func createUserWithEmail(email: String, password: String) async throws
    
    func sendEmailVerification() async throws
    
    func isEmailVerified() async throws -> Bool
    
    func signIn(email: String, password: String) async throws
    
    func signOut() async throws
    
    func resetPassword(email: String) async throws
    
    func isAuthenticated() -> Bool
}
