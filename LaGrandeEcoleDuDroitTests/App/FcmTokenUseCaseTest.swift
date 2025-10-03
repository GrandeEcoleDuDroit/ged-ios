import Testing
import Combine

@testable import GrandeEcoleDuDroit

class FcmTokenUseCaseTest {
    @Test
    func listen_should_send_unsent_token_when_authenticated() {
        // Given
        let unsetFcmToken = UnsetFcmToken()
        let useCase = FcmTokenUseCase(
            userRepository: CurrentUserNotNil(),
            fcmTokenRepository: unsetFcmToken,
            networkMonitor: ConnectedToInternet(),
            listenAuthenticationStateUseCase: Authenticated()
        )
        
        // When
        useCase.listen()
                
        // Then
        #expect(unsetFcmToken.sendTokenCalled)
    }
    
    @Test
    func listen_should_remove_token_when_unauthenticated() {
        // Given
        let removedFcmToken = RemovedFcmToken()
        
        // When
        let useCase = FcmTokenUseCase(
            userRepository: CurrentUserNotNil(),
            fcmTokenRepository: removedFcmToken,
            networkMonitor: ConnectedToInternet(),
            listenAuthenticationStateUseCase: Unauthenticated()
        )
        useCase.listen()
                
        // Then
        #expect(removedFcmToken.removeTokenCalled)
    }
}

private class CurrentUserNotNil: MockUserRepository {
    override var currentUser: User? {
        userFixture
    }
}

private class Authenticated: ListenAuthenticationStateUseCase {
    override init(
        authenticationRepository: any AuthenticationRepository = MockAuthenticationRepository(),
        userRepository: any UserRepository = MockUserRepository()
    ) {
        super.init(
            authenticationRepository: authenticationRepository,
            userRepository: userRepository
        )
    }
    
    override var authenticated: AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }
}

private class Unauthenticated: ListenAuthenticationStateUseCase {
    override init(
        authenticationRepository: any AuthenticationRepository = MockAuthenticationRepository(),
        userRepository: any UserRepository = MockUserRepository()
    ) {
        super.init(
            authenticationRepository: authenticationRepository,
            userRepository: userRepository
        )
    }
    
    override var authenticated: AnyPublisher<Bool, Never> {
        Just(false).eraseToAnyPublisher()
    }
}

private class ConnectedToInternet: MockNetworkMonitor {
    override var connected: AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }
}

private class UnsetFcmToken: MockFcmTokenRepository {
    var sendTokenCalled = false
    
    override func getUnsetToken() async -> FcmToken? {
        FcmToken(userId: userFixture.id, value: "")
    }
    
    override func sendFcmToken(token: FcmToken) async throws {
        sendTokenCalled = true
    }
}

private class RemovedFcmToken: MockFcmTokenRepository {
    var removeTokenCalled = false

    override func removeUnsetToken() async throws {
        removeTokenCalled = true
    }
}
