import Combine

protocol FirebaseAuthenticationRepository {
    var authIdToken: String?{ get }
    
    func isAuthenticated() -> Bool
    
    func loginWithEmailAndPassword(email: String, password: String) async throws
    
    func registerWithEmailAndPassword(email: String, password: String) async throws -> String
    
    func logout()
    
    func resetPassword(email: String) async throws
}
