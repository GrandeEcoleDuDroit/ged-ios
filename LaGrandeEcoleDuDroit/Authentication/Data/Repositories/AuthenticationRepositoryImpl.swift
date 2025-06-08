import Combine
import os
import FirebaseAuth

class AuthenticationRepositoryImpl: AuthenticationRepository {
    private let firebaseAuthenticationRepository: FirebaseAuthenticationRepository
    private let authenticationLocalDataSource: AuthenticationLocalDataSource
    private var authenticatedPublisher = CurrentValueSubject<Bool?, Never>(nil)
    var authenticated: AnyPublisher<Bool, Never> {
        authenticatedPublisher
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    var isAuthenticated: Bool {
        authenticatedPublisher.value ?? false
    }
    
    init(
        firebaseAuthenticationRepository: FirebaseAuthenticationRepository,
        authenticationLocalDataSource: AuthenticationLocalDataSource
    ) {
        self.firebaseAuthenticationRepository = firebaseAuthenticationRepository
        self.authenticationLocalDataSource = authenticationLocalDataSource
        initAuthentication()
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
        authenticatedPublisher.send(isAuthenticated)
    }
    
    func resetPassword(email: String) async throws {
        try await firebaseAuthenticationRepository.resetPassword(email: email)
    }
    
    private func initAuthentication() {
        authenticatedPublisher.send(
            authenticationLocalDataSource.isAuthenticated() &&
                firebaseAuthenticationRepository.isAuthenticated()
        )
    }
}
