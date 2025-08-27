import SwiftUI
import Combine

private let minPasswordLength: Int = 8

class ThirdRegistrationViewModel: ObservableObject {
    private let registerUseCase: RegisterUseCase
    
    @Published var uiState: ThirdRegistrationUiState = ThirdRegistrationUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    
    init(registerUseCase: RegisterUseCase) {
        self.registerUseCase = registerUseCase
    }
    
    func register(firstName: String, lastName: String, schoolLevel: SchoolLevel) {
        let email = uiState.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = uiState.password
        
        guard (validateInputs(email: email, password: password)) else {
            return
        }
        uiState.loading = true
        
        Task {
            do {
                try await registerUseCase.execute(
                    email: uiState.email,
                    password: uiState.password,
                    firstName: firstName,
                    lastName: lastName,
                    schoolLevel: schoolLevel
                )
            } catch let error as RequestError {
                DispatchQueue.main.sync { [weak self] in
                    self?.uiState.loading = false
                    switch error {
                        case .noInternetConnection: self?.event = ErrorEvent(message: getString(.noInternetConectionError))
                        default:
                            self?.uiState.errorMessage = self?.mapErrorMessage(error)
                            self?.uiState.password = ""
                            
                    }
                }
            } catch {
                DispatchQueue.main.sync { [weak self] in
                    self?.uiState.loading = false
                    self?.uiState.errorMessage = self?.mapErrorMessage(error)
                    self?.uiState.password = ""
                }
            }
        }
    }
    
    func validateInputs(email: String, password: String) -> Bool {
        uiState.emailError = validateEmail(email: email)
        uiState.passwordError = validatePassword(password: password)
        return uiState.emailError == nil && uiState.passwordError == nil
    }
    
    private func validateEmail(email: String) -> String? {
        if email.isBlank {
            getString(.mandatoryFieldError)
        } else if !VerifyEmailFormatUseCase.execute(email) {
            getString(.invalidEmailError)
        } else {
            nil
        }
    }
    
    private func validatePassword(password: String) -> String? {
        if password.isBlank {
            getString(.mandatoryFieldError)
        } else if password.count < minPasswordLength {
            getString(.passwordLengthError)
        } else {
            nil
        }
    }
    
    private func mapErrorMessage(_ e: Error) -> String {
        mapNetworkErrorMessage(e) {
            if let authError = e as? AuthenticationError {
                 switch authError {
                     default: getString(.unknownError)
                 }
            } else if let networkError = e as? RequestError {
                switch networkError {
                    case .forbidden: getString(.userNotWhiteListedError)
                    case .dupplicateData: getString(.emailAlreadyAssociatedError)
                    default: getString(.unknownError)
                }
            } else {
                 getString(.unknownError)
             }
        }
    }
    
    struct ThirdRegistrationUiState {
        var email: String = ""
        var password: String = ""
        var loading: Bool = false
        var emailError: String? = nil
        var passwordError: String? = nil
        var errorMessage: String? = nil
    }
}
