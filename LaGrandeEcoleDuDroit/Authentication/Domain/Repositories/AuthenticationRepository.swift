import Combine

protocol AuthenticationRepository {
    var authenticated: AnyPublisher<Bool, Never> { get }
    
    func getAuthToken() async throws -> String?
    
    func loginWithEmailAndPassword(email: String, password: String) async throws -> String
    
    func registerWithEmailAndPassword(email: String, password: String) async throws -> String
    
    func logout()
            
    func setAuthenticated(_ isAuthenticated: Bool)
    
    func resetPassword(email: String) async throws
}
