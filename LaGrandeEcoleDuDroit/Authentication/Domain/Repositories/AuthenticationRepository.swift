import Combine

protocol AuthenticationRepository {
    var authenticated: AnyPublisher<Bool, Never> { get }
    
    var isAuthenticated: Bool { get }
    
    func loginWithEmailAndPassword(email: String, password: String) async throws
    
    func registerWithEmailAndPassword(email: String, password: String) async throws -> String
    
    func logout()
            
    func setAuthenticated(_ isAuthenticated: Bool)
    
    func resetPassword(email: String) async throws
    
    func deleteAuthUser() async throws
}
