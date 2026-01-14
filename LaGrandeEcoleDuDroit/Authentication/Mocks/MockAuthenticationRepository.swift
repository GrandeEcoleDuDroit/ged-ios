import Combine

class MockAuthenticationRepository: AuthenticationRepository {
    func isAuthenticated() async throws -> Bool { false }
    
    func getAuthenticationState() -> AnyPublisher<Bool, Never> {
        Empty().eraseToAnyPublisher()
    }

    func loginWithEmailAndPassword(email: String, password: String) async throws -> String { "" }
    
    func registerWithEmailAndPassword(email: String, password: String) async throws -> String { "" }
    
    func logout() {}
    
    func setAuthenticated(_ isAuthenticated: Bool) {}
        
    func resetPassword(email: String) async throws {}
    
    func deleteAuthUser() async throws {}
    
    func getAuthToken() async throws -> String? { nil }
}
