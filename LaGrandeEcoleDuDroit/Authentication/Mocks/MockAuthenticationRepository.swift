import Foundation
import Combine

class MockAuthenticationRepository: AuthenticationRepository {
    var isAuthenticated = CurrentValueSubject<Bool, Never>(false)
    
    func register(email: String, password: String) async throws -> String {
        isAuthenticated.send(true)
        return ""
    }
    
    func sendEmailVerification() async throws {}
    
    func isEmailVerified() async throws -> Bool {
        true
    }
    
    func login(email: String, password: String) async throws -> String {
        isAuthenticated.send(true)
        return ""
    }
    
    func logout() throws {
        isAuthenticated.send(false)
    }    
}
