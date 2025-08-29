import FirebaseAuth
import Combine

protocol FirebaseAuthApi {
    func isAuthenticated() -> Bool
    
    func getAuthToken() async throws -> String?
    
    func listenTokenChanges(completion: @escaping (String?) -> Void)
        
    func signIn(email: String, password: String) async throws

    func signUp(email: String, password: String) async throws -> String
        
    func signOut()
    
    func resetPassword(email: String) async throws
}
