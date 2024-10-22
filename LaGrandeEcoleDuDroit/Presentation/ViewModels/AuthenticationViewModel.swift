import SwiftUI

class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func validateInputs() -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = NSLocalizedString(GedStrings.empty_inputs_error, comment: "")
            return false
        }

        guard verifyEmailUseCase(email) else {
            errorMessage = NSLocalizedString(GedStrings.invalid_email_error, comment: "")
            return false
        }
        
        guard password.count >= 8 else {
            errorMessage = NSLocalizedString(GedStrings.password_length_error, comment: "")
            return false
        }

        return true
    }
    
    func login() {
        errorMessage = nil
        isLoading = true
        
        // Do the login implementation
    }
}
