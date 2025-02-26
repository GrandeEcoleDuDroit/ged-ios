import SwiftUI
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var authenticationState: AuthenticationState = .idle
    private var cancellables: Set<AnyCancellable> = []
    
    private let loginUseCase: LoginUseCase
    private let isEmailVerifiedUseCase: IsEmailVerifiedUseCase
    private let isAuthenticatedUseCase: IsUserAuthenticatedUseCase
    private let getUserUseCase: GetUserUseCase
    private let setCurrentUserUseCase: SetCurrentUserUseCase
    private let setUserAuthenticatedUseCase: SetUserAuthenticatedUseCase
    
    init(
        loginUseCase: LoginUseCase,
        isEmailVerifiedUseCase: IsEmailVerifiedUseCase,
        isAuthenticatedUseCase: IsUserAuthenticatedUseCase,
        getUserUseCase: GetUserUseCase,
        setCurrentUserUseCase: SetCurrentUserUseCase,
        setUserAuthenticatedUseCase: SetUserAuthenticatedUseCase
    ) {
        self.loginUseCase = loginUseCase
        self.isEmailVerifiedUseCase = isEmailVerifiedUseCase
        self.isAuthenticatedUseCase = isAuthenticatedUseCase
        self.getUserUseCase = getUserUseCase
        self.setCurrentUserUseCase = setCurrentUserUseCase
        self.setUserAuthenticatedUseCase = setUserAuthenticatedUseCase
    }
    
    func validateInputs() -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            authenticationState = .error(message: getString(.emptyInputsError))
            return false
        }
        
        guard VerifyEmailFormatUseCase.execute(email) else {
            authenticationState = .error(message: getString(.invalidEmailError))
            return false
        }
        
        guard password.count >= 8 else {
            authenticationState = .error(message: getString(.passwordLengthError))
            return false
        }
        
        return true
    }
    
    func login() {
        updateAuthenticationState(to: .loading)
        
        Task {
            do {
                try await loginUseCase.execute(email: email, password: password)
                
                if let user = await getUserUseCase.executeWithEmail(email: email) {
                    setCurrentUserUseCase.execute(user: user)
                    if try await isEmailVerifiedUseCase.execute() {
                        await setUserAuthenticatedUseCase.execute(true)
                        updateAuthenticationState(to: .authenticated)
                    } else {
                        updateAuthenticationState(to: .emailNotVerified)
                    }
                } else {
                    updateAuthenticationState(to: .error(message: getString(.userNotExist)))
                    resetPassword()
                }
            } catch AuthenticationError.invalidCredentials {
                updateAuthenticationState(to: .error(message: getString(.invalidCredentials)))
                resetPassword()
            } catch AuthenticationError.userDisabled {
                updateAuthenticationState(to: .error(message: getString(.userDisabled)))
                resetPassword()
            } catch {
                updateAuthenticationState(to: .error(message: getString(.unknownError)))
                resetPassword()
            }
        }
    }
    
    private func resetPassword() {
        if Thread.isMainThread {
            password = ""
        } else {
            DispatchQueue.main.sync { [weak self] in
                self?.password = ""
            }
        }
    }
    
    private func updateAuthenticationState(to state: AuthenticationState) {
        if Thread.isMainThread {
            authenticationState = state
        } else {
            DispatchQueue.main.sync { [weak self] in
                self?.authenticationState = state
            }
        }
    }
}
