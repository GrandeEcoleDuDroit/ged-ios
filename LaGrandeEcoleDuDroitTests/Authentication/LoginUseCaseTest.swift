import Testing

@testable import GrandeEcoleDuDroit

class LoginUseCaseTest {
    @Test
    func loginUseCase_should_throw_timed_out_when_takes_more_than_10_seconds() async throws {
        // Given
        let email = "example@email.com"
        let password = "password123"
        let useCase = LoginUseCase(
            authenticationRepository: TestAuthenticationRepository()
        )
        
        // When
        let error = await #expect(throws: NetworkError.timedOut.self) {
            try await useCase.execute(email: email, password: password)
        }
        
        // Then
        #expect(error == NetworkError.timedOut)
    }
}

private class TestAuthenticationRepository: MockAuthenticationRepository {
    override func loginWithEmailAndPassword(email: String, password: String) async throws -> String {
        try await Task.sleep(for: .seconds(11))
        return "userId"
    }
}
