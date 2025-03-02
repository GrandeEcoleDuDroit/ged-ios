import Combine
import os
import FirebaseAuth

class AuthenticationRepositoryImpl: AuthenticationRepository {
    private let firebaseAuthenticationRepository: FirebaseAuthenticationRepository
    private let authenticationLocalDataSource: AuthenticationLocalDataSource
    private(set) var isAuthenticated: CurrentValueSubject<Bool, Never>
    
    init(
        firebaseAuthenticationRepository: FirebaseAuthenticationRepository,
        authenticationLocalDataSource: AuthenticationLocalDataSource
    ) {
        self.firebaseAuthenticationRepository = firebaseAuthenticationRepository
        self.authenticationLocalDataSource = authenticationLocalDataSource
        isAuthenticated = authenticationLocalDataSource.isAuthenticated
    }
    
    func loginWithEmailAndPassword(email: String, password: String) async throws {
        try await firebaseAuthenticationRepository.loginWithEmailAndPassword(email: email, password: password)
    }
    
    func registerWithEmailAndPassword(email: String, password: String) async throws {
        try await firebaseAuthenticationRepository.registerWithEmailAndPassword(email: email, password: password)
    }
    
    func logout() async {
        Task { try? await firebaseAuthenticationRepository.logout() }
        await setAuthenticated(false)
    }
    
    func sendEmailVerification() async throws {
        try await firebaseAuthenticationRepository.sendEmailVerification()
    }
    
    func isEmailVerified() async throws -> Bool {
        try await firebaseAuthenticationRepository.isEmailVerified()
    }
    
    func setAuthenticated(_ isAuthenticated: Bool) async {
        await authenticationLocalDataSource.setAuthenticated(isAuthenticated)
    }
    
    func resetPassword(email: String) async throws {
        try await firebaseAuthenticationRepository.resetPassword(email: email)
    }
}
