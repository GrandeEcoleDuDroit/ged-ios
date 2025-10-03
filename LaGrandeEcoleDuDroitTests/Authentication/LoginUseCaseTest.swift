import Testing

@testable import GrandeEcoleDuDroit

class LoginUseCaseTest {
    let email = "example@email.com"
    let password = "password123"
    
    @Test
    func loginUseCase_should_throw_authentication_error_when_user_not_exist() async throws {
        // Given
        let useCase = LoginUseCase(
            authenticationRepository: MockAuthenticationRepository(),
            userRepository: UserNotExist()
        )
        
        // When
        let error = await #expect(throws: AuthenticationError.invalidCredentials.self) {
            try await useCase.execute(email: self.email, password: self.password)
        }
        
        // Then
        #expect(error == AuthenticationError.invalidCredentials)
    }
}

private class UserNotExist: MockUserRepository {
    override func getUserWithEmail(email: String) async -> User? {
        nil
    }
}
