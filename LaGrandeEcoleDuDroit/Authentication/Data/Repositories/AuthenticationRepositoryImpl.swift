import Combine
import os
import FirebaseAuth

class AuthenticationRepositoryImpl: AuthenticationRepository {
    private let firebaseAuthenticationRepository: FirebaseAuthenticationRepository
    private let authenticationLocalDataSource: AuthenticationLocalDataSource
    private let authenticationSubjet = PassthroughSubject<Bool, Never>()
    
    init(
        firebaseAuthenticationRepository: FirebaseAuthenticationRepository,
        authenticationLocalDataSource: AuthenticationLocalDataSource
    ) {
        self.firebaseAuthenticationRepository = firebaseAuthenticationRepository
        self.authenticationLocalDataSource = authenticationLocalDataSource
    }
    
    func getAuthenticationState() -> AnyPublisher<Bool, Never> {
        authenticationSubjet
            .prepend(
                authenticationLocalDataSource.isAuthenticated() &&
                    firebaseAuthenticationRepository.isAuthenticated()
            )
            .eraseToAnyPublisher()
    }
    
    func loginWithEmailAndPassword(email: String, password: String) async throws {
        try await firebaseAuthenticationRepository.loginWithEmailAndPassword(email: email, password: password)
    }
    
    func registerWithEmailAndPassword(email: String, password: String) async throws -> String {
        try await firebaseAuthenticationRepository.registerWithEmailAndPassword(email: email, password: password)
    }
    
    func logout() {
        firebaseAuthenticationRepository.logout()
        setAuthenticated(false)
    }
    
    func setAuthenticated(_ isAuthenticated: Bool) {
        authenticationLocalDataSource.setAuthenticated(isAuthenticated)
        authenticationSubjet.send(isAuthenticated)
    }
    
    func resetPassword(email: String) async throws {
        try await firebaseAuthenticationRepository.resetPassword(email: email)
    }
    
    func deleteAuthUser() async throws {
        try await firebaseAuthenticationRepository.deleteAuthUser()
        setAuthenticated(false)
    }
}
