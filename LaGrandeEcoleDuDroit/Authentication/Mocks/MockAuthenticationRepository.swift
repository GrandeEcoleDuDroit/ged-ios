import Combine

class MockAuthenticationRepository: AuthenticationRepository {
    var authenticated: AnyPublisher<Bool, Never> {
        Just(false).eraseToAnyPublisher()
    }
    
    func getAuthToken() async throws -> String? { nil }
    
    func loginWithEmailAndPassword(email: String, password: String) async throws -> String { "" }
    
    func registerWithEmailAndPassword(email: String, password: String) async throws -> String { "" }
    
    func logout() {}
    
    func setAuthenticated(_ isAuthenticated: Bool) {}
        
    func resetPassword(email: String) async throws {}
    
    func deleteAuthUser() async throws {}
}
