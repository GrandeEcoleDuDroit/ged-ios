import SwiftUI

class AuthenticationViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isAuthenticated: Bool = false
    
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
        
        // Do the login implementation
    }
}
