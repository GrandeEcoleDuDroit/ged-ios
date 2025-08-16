import FirebaseAuth
import Combine

protocol FirebaseAuthApi {
    func isAuthenticated() -> Bool
    
    func listenTokenChanges(completion: @escaping (String?) -> Void) -> AuthStateDidChangeListenerHandle
    
    func removeTokenListener(listener: AuthStateDidChangeListenerHandle)
    
    func signIn(email: String, password: String) async throws

    func signUp(email: String, password: String) async throws -> String
        
    func signOut()
    
    func resetPassword(email: String) async throws
}
