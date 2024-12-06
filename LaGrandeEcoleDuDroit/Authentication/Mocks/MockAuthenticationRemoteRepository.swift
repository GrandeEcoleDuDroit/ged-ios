import Foundation
import Combine

class MockAuthenticationRemoteRepository: AuthenticationRemoteRepository {
    @Published private var _isAuthenticated: Bool = false
    var isAuthenticated: AnyPublisher<Bool, Never> {
        $_isAuthenticated.eraseToAnyPublisher()
    }
    
    func register(email: String, password: String) async throws -> String {
        _isAuthenticated = true
        return ""
    }
    
    func sendEmailVerification() async throws {}
    
    func isEmailVerified() async throws -> Bool {
        true
    }
    
    func login(email: String, password: String) async throws -> String {
        _isAuthenticated = true
        return ""
    }
    
    func logout() throws {
        _isAuthenticated = false
    }
    
    
}
