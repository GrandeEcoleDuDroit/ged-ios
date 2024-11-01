import SwiftUI

class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var authenticationState: AuthenticationState = .idle
    
    private let loginUseCase: LoginUseCase = LoginUseCase()
    private let isEmailVerifiedUseCase: IsEmailVerifiedUseCase = IsEmailVerifiedUseCase()
    
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
        authenticationState = .loading
        do {
            try await loginUseCase.execute(email: email, password: password)
            
            if let isVerified = try? await isEmailVerifiedUseCase.execute() {
                if isVerified {
                    authenticationState = .authenticated
                } else {
                    authenticationState = .emailNotVerified
                }
            } else {
                authenticationState = .emailNotVerified
            }
        } catch AuthenticationError.invalidCredentials {
            authenticationState = .error(message: getString(gedString: GedString.invalid_credentials))
        } catch AuthenticationError.userDisabled {
            authenticationState = .error(message: getString(gedString: GedString.user_disabled))
        } catch {
            authenticationState = .error(message: getString(gedString: GedString.unknown_error))
        }
    }
}
