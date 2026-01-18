import Combine

class AuthenticationRemoteDataSource {
    private let authenticationApi: AuthenticationApi
    
    init(authenticationApi: AuthenticationApi) {
        self.authenticationApi = authenticationApi
    }
    
    func listenAuthenticationState() -> AnyPublisher<Bool, Never> {
        authenticationApi.listenAuthenticationState()
    }
    
    func listenAuthTokenState() -> AnyPublisher<AuthTokenState, Never> {
        authenticationApi.listenAuthTokenState()
    }
    
    func getAuthToken() async throws -> String? {
        try await authenticationApi.getAuthToken()
    }
  
    func loginWithEmailAndPassword(email: String, password: String) async throws -> String {
        try await authenticationApi.login(email: email, password: password)
    }
    
    func registerWithEmailAndPassword(email: String, password: String) async throws -> String {
        try await authenticationApi.register(email: email, password: password)
    }
    
    func logout() {
        authenticationApi.logout()
    }
    
    func resetPassword(email: String) async throws {
        try await authenticationApi.resetPassword(email: email)
    }
}
