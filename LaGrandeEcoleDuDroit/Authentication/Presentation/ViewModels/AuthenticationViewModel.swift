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
    
    func login() {
        authenticationState = .loading
        
        loginUseCase.execute(email: email, password: password) { result in
            switch result {
            case .success:
                self.isEmailVerifiedUseCase.execute { isVerified in
                    if isVerified {
                        self.authenticationState = .authenticated
                    } else {
                        self.authenticationState = .emailNotVerified
                    }
                }
            case .failure(let error):
                switch error {
                case .invalidCredentials:
                    self.authenticationState = .error(message: getString(gedString: GedString.invalid_credentials))
                case .userDisabled:
                    self.authenticationState = .error(message: getString(gedString: GedString.user_disabled))
                default:
                    self.authenticationState = .error(message: getString(gedString: GedString.unknown_error))
                }
            }
        }
    }
}
