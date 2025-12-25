import Combine
import os
import FirebaseAuth

class AuthenticationRepositoryImpl: AuthenticationRepository {
    private let authenticationLocalDataSource: AuthenticationLocalDataSource
    private let authenticationRemoteDataSource: AuthenticationRemoteDataSource
    private let authenticationSubjet = PassthroughSubject<Bool, Never>()
    private var token: String?
    private var cancellables = Set<AnyCancellable>()
    
    init(
        authenticationLocalDataSource: AuthenticationLocalDataSource,
        authenticationRemoteDataSource: AuthenticationRemoteDataSource
    ) {
        self.authenticationRemoteDataSource = authenticationRemoteDataSource
        self.authenticationLocalDataSource = authenticationLocalDataSource
        listenToken()
    }
    
    func isAuthenticated() async throws -> Bool {
        let localResult = authenticationLocalDataSource.isAuthenticated()
        let remoteResult = try await authenticationRemoteDataSource.isAuthenticated()
        return localResult && remoteResult
    }
    
    func getAuthenticationState() -> AnyPublisher<Bool, Never> {
        let localAuthenticationState = authenticationLocalDataSource.isAuthenticated()
        return authenticationSubjet
            .prepend(localAuthenticationState)
            .eraseToAnyPublisher()
    }
    
    func loginWithEmailAndPassword(email: String, password: String) async throws -> String {
        try await authenticationRemoteDataSource.loginWithEmailAndPassword(email: email, password: password)
    }
    
    func registerWithEmailAndPassword(email: String, password: String) async throws -> String {
        try await authenticationRemoteDataSource.registerWithEmailAndPassword(email: email, password: password)
    }
    
    func logout() {
        authenticationRemoteDataSource.logout()
        setAuthenticated(false)
    }
    
    func setAuthenticated(_ isAuthenticated: Bool) {
        authenticationLocalDataSource.setAuthenticated(isAuthenticated)
        authenticationSubjet.send(isAuthenticated)
    }
    
    func resetPassword(email: String) async throws {
        try await authenticationRemoteDataSource.resetPassword(email: email)
    }
    
    func getToken() async throws -> String? {
        token != nil ? token : try await authenticationRemoteDataSource.getToken()
    }
    
    private func listenToken() {
        authenticationRemoteDataSource.listenToken().sink { [weak self] token in
            self?.token = token
        }.store(in: &cancellables)
    }
}
