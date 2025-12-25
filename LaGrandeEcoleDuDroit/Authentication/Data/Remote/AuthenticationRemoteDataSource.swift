import Combine

class AuthenticationRemoteDataSource {
    private let authenticationApi: AuthenticationApi
    
    init(authenticationApi: AuthenticationApi) {
        self.authenticationApi = authenticationApi
    }
    
    func isAuthenticated() async throws -> Bool {
        try await authenticationApi.isAuthenticated()
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
    
    func getToken() async throws -> String? {
        try await authenticationApi.getToken()
    }
    
    func listenToken() -> AnyPublisher<String?, Never> {
        authenticationApi.listenToken()
    }
}
