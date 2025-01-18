import XCTest
import Combine
@testable import La_Grande_Ecole_Du_Droit

final class AuthenticationTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!
    private var authenticationRepository: AuthenticationRepository!
    
    private var isAuthenticatedUseCase: IsAuthenticatedUseCase!
    private var isEmailVerifiedUseCase: IsEmailVerifiedUseCase!
    private var loginUseCase: LoginUseCase!
    private var logoutUseCase: LogoutUseCase!
    private var registerUseCase: RegisterUseCase!
    
    override func setUp() {
        cancellables = []
        authenticationRepository = AuthenticationInjection.shared.resolveWithMock().resolve(AuthenticationRepository.self)
        
        isAuthenticatedUseCase = IsAuthenticatedUseCase(authenticationRepository: authenticationRepository)
        isEmailVerifiedUseCase = IsEmailVerifiedUseCase(authenticationRepository: authenticationRepository)
        loginUseCase = LoginUseCase(authenticationRepository: authenticationRepository)
        logoutUseCase = LogoutUseCase(authenticationRepository: authenticationRepository)
        registerUseCase = RegisterUseCase(authenticationRepository: authenticationRepository)
    }
    
    func testIsAuthenticated() {
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
    
    func isEmailVerified() async throws {
        // Given
        var result: Bool = false
        
        // When
        authenticationRepository.isAuthenticated.value = true
        result = try await isEmailVerifiedUseCase.execute()
        
        // Then
        XCTAssertTrue(result)
    }
    
    func testLogin() async throws {
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
    
    func testLogout() throws {
        // Given
        authenticationRepository.isAuthenticated.value = true
        
        // When
        try logoutUseCase.execute()
        
        // Then
        authenticationRepository.isAuthenticated
            .sink { value in
                XCTAssertFalse(value)
            }
            .store(in: &cancellables)
    }
    
    func testRegister() async throws {
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
}
