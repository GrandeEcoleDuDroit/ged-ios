import Testing

@testable import GrandeEcoleDuDroit

class RegisterUseCaseTest {
    let email = "example@email.com"
    let password = "password123"
    let firstName = "John"
    let lastName = "Doe"
    let schoolLevel = SchoolLevel.ged1
    
    @Test
    func registerUseCase_should_throw_forbidden_error_when_user_is_not_whitelisted() async throws {
        let useCase = RegisterUseCase(
            authenticationRepository: MockAuthenticationRepository(),
            userRepository: MockUserRepository(),
            whiteListRepository: MockWhiteListRepository()
        )
        
        // When
        let error = await #expect(throws: NetworkError.forbidden.self) {
            try await useCase.execute(
                email: self.email,
                password: self.password,
                firstName: self.firstName,
                lastName: self.lastName,
                schoolLevel: self.schoolLevel
            )
        }
        
        // Then
        #expect(error == NetworkError.forbidden)
    }
}

private class WhiteListed: MockWhiteListRepository {
    override func isUserWhitelisted(email: String) async throws -> Bool { true }
}
