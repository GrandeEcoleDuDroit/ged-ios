import Combine

protocol AuthenticationRepository {
    func isAuthenticated() async throws -> Bool
    
    func getAuthenticationState() -> AnyPublisher<Bool, Never>
    
    func loginWithEmailAndPassword(email: String, password: String) async throws -> String
    
    func registerWithEmailAndPassword(email: String, password: String) async throws -> String
    
    func logout() 
            
    func setAuthenticated(_ isAuthenticated: Bool)
    
    func resetPassword(email: String) async throws
    
    func deleteAuthUser() async throws
    
    func getToken() async throws -> String?
}
