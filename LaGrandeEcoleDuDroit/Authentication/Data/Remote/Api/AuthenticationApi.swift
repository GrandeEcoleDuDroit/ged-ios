import Combine

protocol AuthenticationApi {
    func listenAuthenticationState() -> AnyPublisher<Bool, Never>
    
    func listenAuthTokenState() -> AnyPublisher<AuthTokenState, Never>

    func getAuthToken() async throws -> String?
    
    func login(email: String, password: String)  async throws -> String

    func register(email: String, password: String) async throws -> String
        
    func logout()
    
    func resetPassword(email: String) async throws
}
