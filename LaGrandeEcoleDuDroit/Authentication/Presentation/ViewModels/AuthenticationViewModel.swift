import SwiftUI

class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var authenticationState: AuthenticationState = .idle
    
    private let loginUseCase: LoginUseCase
    private let isEmailVerifiedUseCase: IsEmailVerifiedUseCase
    private let isAuthenticatedUseCase: IsAuthenticatedUseCase
    private let getUserUseCase: GetUserUseCase
    private let setCurrentUserUseCase: SetCurrentUserUseCase
    
    init(
        loginUseCase: LoginUseCase,
        isEmailVerifiedUseCase: IsEmailVerifiedUseCase,
        isAuthenticatedUseCase: IsAuthenticatedUseCase,
        getUserUseCase: GetUserUseCase,
        setCurrentUserUseCase: SetCurrentUserUseCase
    ) {
        self.loginUseCase = loginUseCase
        self.isEmailVerifiedUseCase = isEmailVerifiedUseCase
        self.isAuthenticatedUseCase = isAuthenticatedUseCase
        self.getUserUseCase = getUserUseCase
        self.setCurrentUserUseCase = setCurrentUserUseCase
        
        authenticationState = if self.isAuthenticatedUseCase.execute() {
            .authenticated
        } else {
            .idle
        }
    }
    
    func validateInputs() -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            authenticationState = .error(message: getString(gedString: GedString.empty_inputs_error))
            return false
        }

        guard VerifyEmailFormatUseCase.execute(email) else {
            authenticationState = .error(message: getString(gedString: GedString.invalid_email_error))
            return false
        }
        
        guard password.count >= 8 else {
            authenticationState = .error(message: getString(gedString: GedString.password_length_error))
            return false
        }

        return true
    }
    
    func login() async {
        await updateAuthenticationState(to: .loading)
        
        do {
            let userId = try await loginUseCase.execute(email: email, password: password)
            
            if try await isEmailVerifiedUseCase.execute() {
                let user = await getUserUseCase.execute(userId: userId)
                if user != nil {
                    setCurrentUserUseCase.execute(user: user!)
                    await updateAuthenticationState(to: .authenticated)
                } else {
                    await updateAuthenticationState(to: .error(message: getString(gedString: GedString.user_not_exist)))
                }
            } else {
                await updateAuthenticationState(to: .emailNotVerified)
            }
        } catch AuthenticationError.invalidCredentials {
            await updateAuthenticationState(to: .error(message: getString(gedString: GedString.invalid_credentials)))
        } catch AuthenticationError.userDisabled {
            await updateAuthenticationState(to: .error(message: getString(gedString: GedString.user_disabled)))
        } catch {
            await updateAuthenticationState(to: .error(message: getString(gedString: GedString.unknown_error)))
        }
    }
    
    private func updateAuthenticationState(to state: AuthenticationState) async {
        await MainActor.run {
            authenticationState = state
        }
    }
}
