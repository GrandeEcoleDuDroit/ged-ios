import Combine

protocol AuthenticationApi {
    func isAuthenticated() async throws -> Bool
    
    func getAuthToken() async throws -> AuthToken?
    
    func listenAuthToken() -> AnyPublisher<AuthToken?, Never>
        
    func login(email: String, password: String)  async throws -> String

    func register(email: String, password: String) async throws -> String
        
    func logout()
    
    func resetPassword(email: String) async throws
}
