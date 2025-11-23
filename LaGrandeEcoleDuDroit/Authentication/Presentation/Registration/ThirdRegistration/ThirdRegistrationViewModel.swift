import SwiftUI
import Combine

class ThirdRegistrationViewModel: ViewModel {
    private let registerUseCase: RegisterUseCase
    private let networkMonitor: NetworkMonitor
    
    @Published private(set) var uiState: ThirdRegistrationUiState = ThirdRegistrationUiState()
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
        uiState.errorMessage = nil
        let email = uiState.email.trim()
        let password = uiState.password
        guard (validateInputs(email: email, password: password)) else {
            return
        }
        guard uiState.legalNoticeChecked else {
            return uiState.errorMessage = stringResource(.legalNoticeError)
        }
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: stringResource(.noInternetConectionError))
        }
        
        uiState.loading = true
        
        Task { @MainActor [weak self] in
            do {
                try await self?.registerUseCase.execute(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName,
                    schoolLevel: schoolLevel
                )
            } catch {
                self?.uiState.loading = false
                self?.uiState.errorMessage = self?.mapErrorMessage(error)
            }
        }
    }
    
    func onLegalNoticeCheckedChange(checked: Bool) {
        uiState.legalNoticeChecked = checked
    }
    
    func onEmailChange(_ email: String) {
        uiState.email = email
    }
    
    func onPasswordChange(_ password: String) {
        uiState.password = password
    }
    
    private func validateInputs(email: String, password: String) -> Bool {
        uiState.emailError = validateEmail(email: email)
        uiState.passwordError = validatePassword(password: password)
        return uiState.emailError == nil && uiState.passwordError == nil
    }
    
    private func validateEmail(email: String) -> String? {
        if email.isBlank() {
            stringResource(.mandatoryFieldError)
        } else if !VerifyEmailFormatUseCase.execute(email) {
            stringResource(.incorrectEmailFormatError)
        } else {
            nil
        }
    }
    
    private func validatePassword(password: String) -> String? {
        if password.isBlank() {
            stringResource(.mandatoryFieldError)
        } else if password.count < minPasswordLength {
            stringResource(.passwordLengthError)
        } else {
            nil
        }
    }
    
    private func mapErrorMessage(_ e: Error) -> String {
        mapNetworkErrorMessage(e) {
            if let authError = e as? AuthenticationError {
                 switch authError {
                     default: stringResource(.unknownError)
                 }
            } else if let networkError = e as? NetworkError {
                switch networkError {
                    case .forbidden: stringResource(.userNotWhiteListedError)
                    case .dupplicateData: stringResource(.emailAlreadyAssociatedError)
                    default: stringResource(.unknownError)
                }
            } else {
                 stringResource(.unknownError)
             }
        }
    }
    
    struct ThirdRegistrationUiState {
        fileprivate(set) var email: String = ""
        fileprivate(set) var password: String = ""
        fileprivate(set) var legalNoticeChecked: Bool = false
        fileprivate(set) var loading: Bool = false
        fileprivate(set) var emailError: String? = nil
        fileprivate(set) var passwordError: String? = nil
        fileprivate(set) var errorMessage: String? = nil
    }
}
