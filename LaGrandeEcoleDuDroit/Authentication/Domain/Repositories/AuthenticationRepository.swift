import Combine

protocol AuthenticationRepository {
    var authenticationState: AnyPublisher<AuthenticationState, Never> { get }
    
    func getAuthToken() async throws -> String?
    
    func loginWithEmailAndPassword(email: String, password: String) async throws -> String
    
    func registerWithEmailAndPassword(email: String, password: String) async throws -> String
    
    func logout()
            
    func storeAuthenticationState(_ state: AuthenticationState)
    
    func resetPassword(email: String) async throws
}
