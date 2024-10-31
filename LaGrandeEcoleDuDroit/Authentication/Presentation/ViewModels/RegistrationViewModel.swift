import SwiftUI
import Combine

class RegistrationViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var schoolLevel: String
    @Published var registrationState: RegistrationState = .idle
    let schoolLevels = ["GED 1", "GED 2", "GED 3", "GED 4"]
    let maxStep = 3
    
    private let registerUseCase: RegisterUseCase = RegisterUseCase()
    private let sendVerificationEmailUseCase: SendVerificationEmailUseCase = SendVerificationEmailUseCase()
    private let isEmailVerifiedUseCase: IsEmailVerifiedUseCase = IsEmailVerifiedUseCase()
    private var cancellables = Set<AnyCancellable>()
    
    init(email: String? = nil) {
        schoolLevel = schoolLevels[0]
        self.email = email ?? ""
    }
    
    func validateNameInputs() -> Bool {
        guard !firstName.isEmpty, !lastName.isEmpty else {
            self.registrationState = .error(message: getString(gedString: GedString.empty_inputs_error))
            return false
        }
        
        return true
    }
    
    func validateCredentialInputs() -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            self.registrationState = .error(message: getString(gedString: GedString.empty_inputs_error))
            return false
        }
        
        guard verifyEmail(email) else {
            self.registrationState = .error(message: getString(gedString: GedString.invalid_email_error))
            return false
        }
        
        guard password.count >= 8 else {
            self.registrationState = .error(message: getString(gedString: GedString.password_length_error))
            return false
        }
        
        return true
    }
    
    func register() {
        self.registrationState = .loading
        let formattedEmail = email.trimmedAndCapitalized()
        let formattedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        registerUseCase.execute(email: formattedEmail, password: formattedPassword) { result in
            switch result {
            case .success:
                self.registrationState = .registered
            case .failure(let error):
                switch error {
                case .accountAlreadyExist:
                    self.registrationState = .error(message: getString(gedString: GedString.account_already_in_use_error))
                case .userNotFound:
                    self.registrationState = .error(message: getString(gedString: GedString.user_not_found))
                default:
                    self.registrationState = .error(message: getString(gedString: GedString.registration_error))
                }
            }
        }
    }
    
    func sendVerificationEmail() {
        registrationState = .loading
        
        sendVerificationEmailUseCase.execute { result in
            switch result {
            case .success:
                self.registrationState = .idle
            case .failure(let error):
                switch error {
                case .tooManyRequest:
                    self.registrationState = .error(message: getString(gedString: GedString.too_many_request_error))
                default:
                    self.registrationState = .error(message: getString(gedString: GedString.unknown_error))
                }
            }
        }
    }
    
    func checkVerifiedEmail() {
        registrationState = .loading

        isEmailVerifiedUseCase.execute { isVerified in
            if isVerified {
                self.registrationState = .emailVerified
            } else {
                self.registrationState = .error(message: getString(gedString: GedString.email_not_verified_error))
            }
        }
    }
}
