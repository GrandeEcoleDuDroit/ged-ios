import Foundation
import Combine

class MockAuthenticationRepository: AuthenticationRepository {
    var isAuthenticated = CurrentValueSubject<Bool, Never>(false)

    func loginWithEmailAndPassword(email: String, password: String) async throws {
        isAuthenticated.send(true)
    }
    
    func registerWithEmailAndPassword(email: String, password: String) async throws {
        isAuthenticated.send(true)
    }
    
    func logout() async {
        isAuthenticated.send(false)
    }
    
    func setAuthenticated(_ isAuthenticated: Bool) async {
        self.isAuthenticated.send(isAuthenticated)
    }
    
    func sendEmailVerification() async throws {}
    
    func isEmailVerified() async throws -> Bool { true }
}
