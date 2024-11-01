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
            registrationState = .error(message: getString(gedString: GedString.empty_inputs_error))
            return false
        }
        
        return true
    }
    
    func validateCredentialInputs() -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            registrationState = .error(message: getString(gedString: GedString.empty_inputs_error))
            return false
        }
        
        guard verifyEmail(email) else {
            registrationState = .error(message: getString(gedString: GedString.invalid_email_error))
            return false
        }
        
        guard password.count >= 8 else {
            registrationState = .error(message: getString(gedString: GedString.password_length_error))
            return false
        }
        
        return true
    }
    
    func register() async {
        registrationState = .loading
        let formattedEmail = email.trimmedAndCapitalized()
        let formattedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            let userId = try await registerUseCase.execute(email: formattedEmail, password: formattedPassword)
            registrationState = .registered
        } catch AuthenticationError.accountAlreadyExist {
            registrationState = .error(message: getString(gedString: GedString.account_already_in_use_error))
        } catch AuthenticationError.userNotFound {
            registrationState = .error(message: getString(gedString: GedString.user_not_found))
        } catch {
            registrationState = .error(message: getString(gedString: GedString.registration_error))
        }
    }
    
    func sendVerificationEmail() async {
        registrationState = .loading
        do {
            try await sendVerificationEmailUseCase.execute()
            registrationState = .idle
        } catch AuthenticationError.tooManyRequest {
            registrationState = .error(message: getString(gedString: GedString.too_many_request_error))
        } catch {
            registrationState = .error(message: getString(gedString: GedString.registration_error))
        }
    }
    
    func checkVerifiedEmail() async {
        registrationState = .loading

        if let emailVerified = try? await isEmailVerifiedUseCase.execute() {
            if emailVerified {
                registrationState = .emailVerified
            } else {
                registrationState = .error(message: getString(gedString: GedString.email_not_verified_error))
            }
        } else {
            registrationState = .error(message: getString(gedString: GedString.email_not_verified_error))
        }
    }
}
