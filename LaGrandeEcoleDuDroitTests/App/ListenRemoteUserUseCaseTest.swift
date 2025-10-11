import Testing
import Combine

@testable import GrandeEcoleDuDroit

class ListenRemoteUserUseCaseTest {
    @Test
    func start_should_store_new_user() async throws {
        // Given
        let userStored = UserStored()
        let useCase = ListenRemoteUserUseCase(
            authenticationRepository: MockAuthenticationRepository(),
            userRepository: userStored
        )
        
        // When
        useCase.start()
       
        // Then
        #expect(userStored.userStored)
    }
    
    @Test
    func start_should_logout_when_user_is_null() async throws {
        // Given
        let logoutCalled = LogoutCalled()
        let useCase = ListenRemoteUserUseCase(
            authenticationRepository: logoutCalled,
            userRepository: NilRemoteUser()
        )
        
        // When
        useCase.start()
       
        // Then
        #expect(logoutCalled.logoutCalled)
    }
}

private class NilRemoteUser: MockUserRepository {
    override var user: AnyPublisher<User, Never> {
        Just(userFixture).compactMap { $0 }.eraseToAnyPublisher()
    }
    
    override func getUserPublisher(userId: String) -> AnyPublisher<User?, Never> {
        Just(nil).eraseToAnyPublisher()
    }
}

private class UserStored: MockUserRepository {
    var userStored: Bool = false
    var storedUserCalled = CurrentValueSubject<Bool?, Never>(nil)
    
    override var user: AnyPublisher<User, Never> {
        Just(userFixture).eraseToAnyPublisher()
    }
    
    override func getUserPublisher(userId: String) -> AnyPublisher<User?, Never> {
        Just(userFixture2).eraseToAnyPublisher()
    }
    
    override func storeUser(_ user: User) {
        userStored = true
        storedUserCalled.send(true)
    }
}

private class LogoutCalled: MockAuthenticationRepository {
    var logoutCalled: Bool = false
    
    override func logout() {
        logoutCalled = true
    }
}
