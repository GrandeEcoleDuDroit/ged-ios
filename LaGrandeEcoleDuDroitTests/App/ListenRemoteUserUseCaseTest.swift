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
}

private class UserStored: MockUserRepository {
    var userStored: Bool = false
    var storedUserCalled = CurrentValueSubject<Bool?, Never>(nil)
    
    override var user: AnyPublisher<User, Never> {
        Just(userFixture).eraseToAnyPublisher()
    }
    
    override func getUserPublisher(userId: String, currentUser: User) -> AnyPublisher<User?, Error> {
        Just(userFixture2)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    override func storeUser(_ user: User) {
        userStored = true
        storedUserCalled.send(true)
    }
}
