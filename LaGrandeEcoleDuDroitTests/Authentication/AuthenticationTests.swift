import XCTest
import Combine
@testable import La_Grande_Ecole_Du_Droit

final class AuthenticationTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!
    private var authenticationRepository: AuthenticationRepository!

    private var isEmailVerifiedUseCase: IsEmailVerifiedUseCase!
    private var loginUseCase: LoginUseCase!
    private var logoutUseCase: LogoutUseCase!
    private var registerUseCase: RegisterUseCase!
    private var isAuthenticatedUseCase: IsUserAuthenticatedUseCase!
    private var setUserAuthenticatedUseCase: SetUserAuthenticatedUseCase!
    
    override func setUp() {
        cancellables = []
        authenticationRepository = AuthenticationInjection.shared.resolveWithMock().resolve(AuthenticationRepository.self)
        
        isEmailVerifiedUseCase = IsEmailVerifiedUseCase(authenticationRepository: authenticationRepository)
        loginUseCase = LoginUseCase(authenticationRepository: authenticationRepository)
        logoutUseCase = LogoutUseCase(authenticationRepository: authenticationRepository)
        registerUseCase = RegisterUseCase(authenticationRepository: authenticationRepository)
        isAuthenticatedUseCase = IsUserAuthenticatedUseCase(authenticationRepository: authenticationRepository)
        setUserAuthenticatedUseCase = SetUserAuthenticatedUseCase(authenticationRepository: authenticationRepository)
    }
    
    func testIsEmailVerifiedUseCase() async throws {
        // Given
        var result: Bool = false
        
        // When
        result = try await isEmailVerifiedUseCase.execute()
        
        // Then
        XCTAssertTrue(result)
    }
    
    func testLoginUseCase() async throws {
        // Given
        let email: String = "email@example.com"
        let password: String = "password"
        authenticationRepository.isAuthenticated.value = false
        
        // When
        try await loginUseCase.execute(email: email, password: password)
        
        // Then
        authenticationRepository.isAuthenticated
            .sink { value in
                XCTAssertTrue(value)
            }
            .store(in: &cancellables)
    }
    
    func testLogoutUseCase() async {
        // Given
        authenticationRepository.isAuthenticated.value = true
        
        // When
        await logoutUseCase.execute()
        
        // Then
        authenticationRepository.isAuthenticated
            .sink { value in
                XCTAssertFalse(value)
            }
            .store(in: &cancellables)
    }
    
    func testRegisterUseCase() async throws {
        // Given
        let email: String = "email@example.com"
        let password: String = "password"
        authenticationRepository.isAuthenticated.value = false
        
        // When
        try await registerUseCase.execute(email: email, password: password)
        
        // Then
        authenticationRepository.isAuthenticated
            .sink { value in
                XCTAssertTrue(value)
            }
            .store(in: &cancellables)
    }
    
    func testIsAuthenticatedUseCase() {
        // Given
        var result: Bool = false
        
        // When
        authenticationRepository.isAuthenticated.value = true
        isAuthenticatedUseCase.execute()
            .sink { value in
                result = value
            }
            .store(in: &cancellables)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func testSetUserAuthenticatedUseCase() async {
        // Given
        let isAuthenticated: Bool = true
        
        // When
        await setUserAuthenticatedUseCase.execute(isAuthenticated)
        
        // Then
        XCTAssertTrue(authenticationRepository.isAuthenticated.value)
    }
}
