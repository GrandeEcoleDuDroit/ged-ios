import SwiftUI

class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var authenticationState: AuthenticationState = .idle
    
    private let loginUseCase: LoginUseCase = LoginUseCase()
    private let isEmailVerifiedUseCase: IsEmailVerifiedUseCase = IsEmailVerifiedUseCase()
    private let isAuthenticatedUseCase: IsAuthenticatedUseCase = IsAuthenticatedUseCase()
    private let getUserUseCase: GetUserUseCase = GetUserUseCase()
    private let setCurretUserUseCase: SetCurretUserUseCase = SetCurretUserUseCase()
    
    init() {
        authenticationState = if isAuthenticatedUseCase.execute() {
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

        guard verifyEmail(email) else {
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
            
            if let isVerified = try? await isEmailVerifiedUseCase.execute() {
                if isVerified {
                    let user = await getUserUseCase.executre(userId: userId)
                    if user != nil {
                        setCurretUserUseCase.execute(user: user!)
                        await updateAuthenticationState(to: .authenticated)
                    } else {
                        await updateAuthenticationState(to: .error(message: getString(gedString: GedString.user_not_exist)))
                    }
                } else {
                    authenticationState = .emailNotVerified
                }
            } else {
                authenticationState = .emailNotVerified
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
