import SwiftUI
import Combine

class RegistrationViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var schoolLevel: String
    @Published var isRegistered: Bool = false
    @Published var isEmailVerified: Bool = false
    let schoolLevels = ["GED 1", "GED 2", "GED 3", "GED 4"]
    let maxStep = 3
    
    private let registerUseCase: RegisterUseCase = RegisterUseCase()
    private let sendVerificationEmailUseCase: SendVerificationEmailUseCase = SendVerificationEmailUseCase()
    private let isEmailVerifiedUseCase: IsEmailVerifiedUseCase = IsEmailVerifiedUseCase()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        schoolLevel = schoolLevels[0]
    }
    
    func resetErrorMessage() {
        errorMessage = nil
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
    
    func register() {
        self.isLoading = true
        registerUseCase.execute(email: email, password: password) { result in
            self.isLoading = false
            switch result {
            case .success:
                self.isRegistered = true
                self.errorMessage = nil
            case .failure(let error):
                switch error {
                case .accountAlreadyExist:
                    self.errorMessage = getString(gedString: GedString.account_already_in_use_error)
                default:
                    self.errorMessage = getString(gedString: GedString.registration_error)
                }
                self.isRegistered = false
            }
        }
    }
    
    func sendVerificationEmail() {
        sendVerificationEmailUseCase.execute { success in
            if !success {
                self.errorMessage = getString(gedString: GedString.unknown_error)
            }
        }
    }
    
    func checkVerifiedEmail() {
        isEmailVerifiedUseCase.execute { isVerified in
            if isVerified {
                self.isEmailVerified = true
            } else {
                self.errorMessage = getString(gedString: GedString.email_not_verified_error)
                self.isEmailVerified = false
            }
        }
    }
}
