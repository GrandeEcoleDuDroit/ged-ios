import Foundation
import Combine

class MockAuthenticationRepository: AuthenticationRepository {
    private let authenticationPublisher = CurrentValueSubject<Bool, Never>(false)
    var authenticated: AnyPublisher<Bool, Never> {
        authenticationPublisher.eraseToAnyPublisher()
    }
    
    var isAuthenticated: Bool {
        authenticationPublisher.value
    }

    func loginWithEmailAndPassword(email: String, password: String) async throws {
        authenticationPublisher.send(true)
    }
    
    func registerWithEmailAndPassword(email: String, password: String) async throws -> String {
        authenticationPublisher.send(true)
        return userFixture.id
    }
    
    func logout() {
        authenticationPublisher.send(false)
    }
    
    func setAuthenticated(_ isAuthenticated: Bool) {
        authenticationPublisher.send(isAuthenticated)
    }
        
    func resetPassword(email: String) async throws {}
}
