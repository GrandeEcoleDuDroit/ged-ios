import Testing

@testable import GrandeEcoleDuDroit

class LoginUseCaseTest {
    let email = "example@email.com"
    let password = "password123"
    
    @Test
    func loginUseCase_should_throw_auth_user_not_found_when_user_not_exist() async throws {
        // Given
        let useCase = LoginUseCase(
            authenticationRepository: MockAuthenticationRepository(),
            userRepository: TestUserRepository()
        )
        
        // When
        let error = await #expect(throws: AuthenticationError.authUserNotFound.self) {
            try await useCase.execute(email: self.email, password: self.password)
        }
        
        // Then
        #expect(error == AuthenticationError.authUserNotFound)
    }
}

private class TestUserRepository: MockUserRepository {
    override func getUser(userId: String) async -> User? {
        nil
    }
}
