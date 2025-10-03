import Testing
import Combine

@testable import GrandeEcoleDuDroit

class ListenAuthenticationStateUseCaseTest {
    
    @Test
    func listenAuthenticationState_should_logout_when_user_not_exist() {
        // Given
        let logoutCalled = LogoutCalled()
        
        // When
        ListenAuthenticationStateUseCase(
            authenticationRepository: logoutCalled,
            userRepository: UserNotExist()
        )
                
        // Then
        #expect(logoutCalled.logoutCalled)
    }
    
    @Test
    func listenAuthenticationState_should_return_authentication_state() async throws {
        // Given
        let useCase = ListenAuthenticationStateUseCase(
            authenticationRepository: Authenticated(),
            userRepository: UserExist()
        )
        
        // Then
        var iterator = useCase.authenticated.values.makeAsyncIterator()
        let first = await iterator.next()
        #expect(first == true)
    }
}

private class UserNotExist: MockUserRepository {
    override func getUserWithEmail(email: String) async -> User? {
        nil
    }
}

private class UserExist: MockUserRepository {
    override func getUserWithEmail(email: String) async -> User? {
        userFixture
    }
}

private class LogoutCalled: MockAuthenticationRepository {
    var logoutCalled = false
    
    override func logout() {
        logoutCalled = true
    }
}

private class Authenticated: MockAuthenticationRepository {
    override func getAuthenticationState() -> AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }
}
