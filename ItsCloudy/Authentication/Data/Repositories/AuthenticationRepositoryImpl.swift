import Combine
import os
import FirebaseAuth

class AuthenticationRepositoryImpl: AuthenticationRepository {
    private let authenticationLocalDataSource: AuthenticationLocalDataSource
    private let authenticationRemoteDataSource: AuthenticationRemoteDataSource
    private var authToken: String?
    private var cancellables = Set<AnyCancellable>()
    private let tag = String(describing: AuthenticationRepositoryImpl.self)
    
    private let authenticatedSubjet = CurrentValueSubject<AuthenticationState?, Never>(nil)
    var authenticationState: AnyPublisher<AuthenticationState, Never> {
        authenticatedSubjet
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    init(
        authenticationLocalDataSource: AuthenticationLocalDataSource,
        authenticationRemoteDataSource: AuthenticationRemoteDataSource
    ) {
        self.authenticationRemoteDataSource = authenticationRemoteDataSource
        self.authenticationLocalDataSource = authenticationLocalDataSource
        
        listenAuthenticationState()
        listenAuthTokenState()
    }
    
    func getAuthToken() async throws -> String? {
        if let authToken {
            return authToken
        } else {
            let token = try await authenticationRemoteDataSource.getAuthToken()
            self.authToken = token
            return token
        }
    }
    
    func loginWithEmailAndPassword(email: String, password: String) async throws -> String {
        do {
            return try await authenticationRemoteDataSource.loginWithEmailAndPassword(email: email, password: password)
        } catch {
            e(tag, "Error log in with email and password", error)
            throw error
        }
    }
    
    func registerWithEmailAndPassword(email: String, password: String) async throws -> String {
        do {
            return try await authenticationRemoteDataSource.registerWithEmailAndPassword(email: email, password: password)
        } catch {
            e(tag, "Error registering with email and password", error)
            throw error
        }
    }
    
    func logout() {
        authenticationRemoteDataSource.logout()
        storeAuthenticationState(.unauthenticated)
    }
    
    func storeAuthenticationState(_ state: AuthenticationState) {
        authenticationLocalDataSource.storeAuthenticationState(state)
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await authenticationRemoteDataSource.resetPassword(email: email)
        } catch {
            e(tag, "Error resetting password for user \(email)", error)
            throw error
        }
    }
    
    private func listenAuthenticationState() {
        Publishers.Merge(
            authenticationLocalDataSource.listenAuthenticationState(),
            authenticationRemoteDataSource.listenAuthenticationState().filter { $0 == .unauthenticated }
        ).sink { [weak self] in
            self?.authenticatedSubjet.send($0)
        }.store(in: &cancellables)
    }
    
    private func listenAuthTokenState() {
        authenticationRemoteDataSource.listenAuthTokenState().sink { [weak self] state in
            switch state {
                case let .valid(token): self?.authToken = token

                case .unauthenticated: self?.authToken = nil

                case let .error(error):
                    e(self?.tag ?? "AuthenticationRepositoryImpl", "Error getting auth token", error)
            }
        }.store(in: &cancellables)
    }
}
