import Testing
import XCTest
import Combine

@testable import GrandeEcoleDuDroit

class CheckUserValidityUseCaseTest {
    @Test
    func execute_should_logout_when_user_nil_and_authenticated() async throws {
        // Given
        let authenticationRepositoryTest = AuthenticationRepositoryTest()
        let useCase = CheckUserValidityUseCase(
            authenticationRepository: authenticationRepositoryTest,
            userRepository: UserRepositoryTest(givenCurrentUser: nil)
        )
        
        // When
        await useCase.execute()
        
        // Then
        #expect(!authenticationRepositoryTest.logoutCalled)
    }
}

private class UserRepositoryTest: MockUserRepository {
    private let givenCurrentUser: User?
    
    init(givenCurrentUser: User?) {
        self.givenCurrentUser = givenCurrentUser
    }
    
    override var currentUser: User? {
        givenCurrentUser
    }
}

private class AuthenticationRepositoryTest: MockAuthenticationRepository {
    var logoutCalled = false
    
    override func logout() {
        logoutCalled = true
    }
}
