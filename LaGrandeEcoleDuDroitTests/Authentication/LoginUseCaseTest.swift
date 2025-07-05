import Testing

@testable import GrandeEcoleDuDroit

class LoginUseCaseTest {
    let email = "example@email.com"
    let password = "password123"
    
    @Test
    func loginUseCase_should_throw_internet_connection_error_when_no_internet() async throws {
        // Given
        let useCase = LoginUseCase(
            authenticationRepository: MockAuthenticationRepository(),
            userRepository: MockUserRepository(),
            networkMonitor: MockNetworkMonitor()
        )
        
        // When
        let error = await #expect(throws: NetworkError.noInternetConnection.self) {
            try await useCase.execute(email: self.email, password: self.password)
        }
        
        // Then
        #expect(error == NetworkError.noInternetConnection)
    }
    
    @Test
    func loginUseCase_should_throw_authentication_error_when_user_not_exist() async throws {
        // Given
        let useCase = LoginUseCase(
            authenticationRepository: MockAuthenticationRepository(),
            userRepository: UserNotExist(),
            networkMonitor: InternetConnection()
        )
        
        // When
        let error = await #expect(throws: AuthenticationError.invalidCredentials.self) {
            try await useCase.execute(email: self.email, password: self.password)
        }
        
        // Then
        #expect(error == AuthenticationError.invalidCredentials)
    }
}

private class InternetConnection: MockNetworkMonitor {
    override var isConnected: Bool { true }
}

private class UserNotExist: MockUserRepository {
    override func getUserWithEmail(email: String) async -> User? {
        nil
    }
}
