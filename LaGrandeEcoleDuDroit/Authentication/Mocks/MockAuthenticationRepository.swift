import Combine

class MockAuthenticationRepository: AuthenticationRepository {
    var authenticationState: AnyPublisher<AuthenticationState, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    func getAuthToken() async throws -> String? { nil }
    
    func loginWithEmailAndPassword(email: String, password: String) async throws -> String { "" }
    
    func registerWithEmailAndPassword(email: String, password: String) async throws -> String { "" }
    
    func logout() {}
    
    func storeAuthenticationState(_ state: AuthenticationState) {}
        
    func resetPassword(email: String) async throws {}
    
    func deleteAuthUser() async throws {}
}
