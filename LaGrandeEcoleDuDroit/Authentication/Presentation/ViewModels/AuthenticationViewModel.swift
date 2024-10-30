import SwiftUI

class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isAuthenticated: Bool = false
    
    private let loginUseCase: LoginUseCase = LoginUseCase()
    
    func validateInputs() -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = NSLocalizedString(GedString.empty_inputs_error, comment: "")
            return false
        }

        guard verifyEmail(email) else {
            errorMessage = NSLocalizedString(GedString.invalid_email_error, comment: "")
            return false
        }
        
        guard password.count >= 8 else {
            errorMessage = NSLocalizedString(GedString.password_length_error, comment: "")
            return false
        }

        return true
    }
    
    func login() {
        errorMessage = nil
        isLoading = true
        
        loginUseCase.execute(email: email, password: password) { result in
            self.isLoading = false
            switch result {
            case .success:
                self.isAuthenticated = true
            case .failure(let error):
                switch error {
                case .invalidCredentials:
                    self.errorMessage = getString(gedString: GedString.invalid_credentials)
                case .userDisabled:
                    self.errorMessage = getString(gedString: GedString.user_disabled)
                default:
                    self.errorMessage = getString(gedString: GedString.unknown_error)
                }
                self.isAuthenticated = false
            }
        }
    }
}
