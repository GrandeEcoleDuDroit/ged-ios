import Testing
import Combine

@testable import GrandeEcoleDuDroit

class ListenAuthenticationStateUseCaseTest {
    @Test
    func listenAuthenticationState_should_return_authentication_state() async throws {
        // Given
        let useCase = ListenAuthenticationStateUseCase(
            authenticationRepository: Authenticated()
        )
        
        // Then
        var iterator = useCase.authenticated.values.makeAsyncIterator()
        let first = await iterator.next()
        #expect(first == true)
    }
}

private class Authenticated: MockAuthenticationRepository {
    override func getAuthenticationState() -> AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }
}
