import Testing

@testable import GrandeEcoleDuDroit

class LoginUseCaseTest {
    let email = "example@email.com"
    let password = "password123"
    
    @Test
    func loginUseCase_should_throw_user_not_found_when_user_not_exist() async throws {
        // Given
        let useCase = LoginUseCase(
            authenticationRepository: MockAuthenticationRepository(),
            userRepository: UserNotExist()
        )
        
        // When
        let error = await #expect(throws: AuthenticationError.userNotFound.self) {
            try await useCase.execute(email: self.email, password: self.password)
        }
        
        // Then
        #expect(error == AuthenticationError.userNotFound)
    }
}

private class UserNotExist: MockUserRepository {
    override func getUser(userId: String) async -> User? {
        nil
    }
}
