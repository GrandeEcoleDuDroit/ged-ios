import Testing
import XCTest
import Combine

@testable import GrandeEcoleDuDroit

class CheckUserValidityUseCaseTest {
    @Test
    func execute_should_do_nothing_when_no_internet_connection() {
        // Given
        let expectation = XCTestExpectation(description: "Timeout test")
        let isAuthenticatedCalled = IsAuthenticatedCalled()
        let useCase = CheckUserValidityUseCase(
            authenticationRepository: isAuthenticatedCalled,
            userRepository: CurrentUserExist(),
            networkMonitor: ConnectedToInternet(false)
        )
        
        // When
        Task {
            try? await withTimeout(2.0) {
                await useCase.execute()
            }
            expectation.fulfill()
        }
        
        // Then
        #expect(!isAuthenticatedCalled.isAuthenticatedCalled)
    }
    
    @Test
    func execute_should_logout_when_user_nil_and_authenticated() async throws {
        // Given
        let logoutCalled = LogoutCalled()
        let useCase = CheckUserValidityUseCase(
            authenticationRepository: logoutCalled,
            userRepository: CurrentUserExist(),
            networkMonitor: ConnectedToInternet()
        )
        
        // When
        await useCase.execute()
        
        // Then
        #expect(!logoutCalled.logoutCalled)
    }
    
    @Test
    func execute_should_logout_when_throw_user_disabled_error() async throws {
        // Given
        let throwUserDisabled = ThrowUserDisabled()
        let useCase = CheckUserValidityUseCase(
            authenticationRepository: throwUserDisabled,
            userRepository: CurrentUserExist(),
            networkMonitor: ConnectedToInternet()
        )
        
        // When
        await useCase.execute()
        
        // Then
        #expect(throwUserDisabled.logoutCalled)
    }
}

private class ConnectedToInternet: MockNetworkMonitor {
    private let givenConnected: Bool
    
    init(_ connected: Bool = true) {
        self.givenConnected = connected
    }
    
    override var connected: AnyPublisher<Bool, Never> {
        Just(givenConnected).eraseToAnyPublisher()
    }
}

private class CurrentUserExist: MockUserRepository {
    override var currentUser: User? {
        userFixture
    }
}

private class CurrentUserNil: MockUserRepository {
    override var currentUser: User? {
        nil
    }
}

private class LogoutCalled: MockAuthenticationRepository {
    var logoutCalled = false
    
    override func logout() {
        logoutCalled = true
    }
}

private class IsAuthenticatedCalled: MockAuthenticationRepository {
    var isAuthenticatedCalled = false
    
    override func isAuthenticated() async throws -> Bool {
        isAuthenticatedCalled = true
        return true
    }
}

private class ThrowUserDisabled: MockAuthenticationRepository {
    var logoutCalled = false
    
    override func isAuthenticated() async throws -> Bool {
        throw AuthenticationError.userDisabled
    }
    
    override func logout() {
        logoutCalled = true
    }
}
