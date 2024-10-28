import SwiftUI

class RegistrationViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var schoolLevel: String
    let schoolLevels = ["GED 1", "GED 2", "GED 3", "GED 4"]
    let maxStep = 3
    
    init() {
        schoolLevel = schoolLevels[0]
    }
    
    func validateNameInputs() -> Bool {
        guard !firstName.isEmpty, !lastName.isEmpty else {
            errorMessage = NSLocalizedString(GedString.empty_inputs_error, comment: "")
            return false
        }
        
        return true
    }
    
    func validateCredentialInputs() -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = NSLocalizedString(GedString.empty_inputs_error, comment: "")
            return false
        }

        guard verifyEmailUseCase(email) else {
            errorMessage = NSLocalizedString(GedString.invalid_email_error, comment: "")
            return false
        }
        
        guard password.count >= 8 else {
            errorMessage = NSLocalizedString(GedString.password_length_error, comment: "")
            return false
        }

        return true
    }
    
    func sendEmailVerification() {
        
    }
}
