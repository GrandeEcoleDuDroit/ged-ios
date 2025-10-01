import SwiftUI
import Combine

class ThirdRegistrationViewModel: ViewModel {
    private let registerUseCase: RegisterUseCase
    private let networkMonitor: NetworkMonitor
    
    @Published var uiState: ThirdRegistrationUiState = ThirdRegistrationUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private let minPasswordLength: Int = 8
    
    init(
        registerUseCase: RegisterUseCase,
        networkMonitor: NetworkMonitor
    ) {
        self.registerUseCase = registerUseCase
        self.networkMonitor = networkMonitor
    }
    
    func register(firstName: String, lastName: String, schoolLevel: SchoolLevel) {
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: getString(.noInternetConectionError))
        }
        
        let email = uiState.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = uiState.password
        guard (validateInputs(email: email, password: password)) else {
            return
        }
        
        uiState.loading = true
        
        Task { [weak self] in
            do {
                try await self?.registerUseCase.execute(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName,
                    schoolLevel: schoolLevel
                )
            } catch let error as NetworkError {
                self?.uiState.loading = false
                switch error {
                    case .noInternetConnection: self?.event = ErrorEvent(message: getString(.noInternetConectionError))
                    default:
                        self?.uiState.errorMessage = self?.mapErrorMessage(error)
                        self?.uiState.password = ""
                        
                }
            } catch {
                self?.uiState.loading = false
                self?.uiState.errorMessage = self?.mapErrorMessage(error)
                self?.uiState.password = ""
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
            } else if let networkError = e as? NetworkError {
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
        fileprivate(set) var loading: Bool = false
        fileprivate(set) var emailError: String? = nil
        fileprivate(set) var passwordError: String? = nil
        fileprivate(set) var errorMessage: String? = nil
    }
}
