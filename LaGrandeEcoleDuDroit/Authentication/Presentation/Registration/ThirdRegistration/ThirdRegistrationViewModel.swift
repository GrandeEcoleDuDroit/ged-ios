import SwiftUI
import Combine

class ThirdRegistrationViewModel: ViewModel {
    private let registerUseCase: RegisterUseCase
    
    @Published var uiState = ThirdRegistrationUiState()
    private let minPasswordLength: Int = 8
    
    init(registerUseCase: RegisterUseCase) {
        self.registerUseCase = registerUseCase
    }
    
    func register(firstName: String, lastName: String, schoolLevel: SchoolLevel) {
        uiState.errorMessage = nil
        let (email, password) = (uiState.email.trim(), uiState.password)
        
        guard (validateInputs(email: email, password: password)) else { return }
        guard uiState.legalNoticeChecked else {
            uiState.errorMessage = stringResource(.legalNoticeNotAcceptedError)
            return
        }
        
        performUiBlockingRequest(
            block: { [weak self] in
                try await self?.registerUseCase.execute(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName,
                    schoolLevel: schoolLevel
                )
            },
            onLoading: { [weak self] in
                self?.uiState.loading = true
            },
            onError: { [weak self] in
                self?.handleError($0)
            },
            onFinshed: { [weak self] in
                self?.uiState.loading = false
            }
        )
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
    
    private func handleError(_ error: Error) {
        let message = if let networkError = error as? NetworkError {
            switch networkError {
                case .forbidden: stringResource(.userNotWhiteListedError)
                case .dupplicateData: stringResource(.emailAlreadyAssociatedError)
                default: networkError.localizedDescription
            }
        } else {
            error.localizedDescription
        }
        
        uiState.errorMessage = message
    }
    
    struct ThirdRegistrationUiState {
        var email: String = ""
        var password: String = ""
        var legalNoticeChecked: Bool = false
        fileprivate(set) var loading: Bool = false
        fileprivate(set) var emailError: String? = nil
        fileprivate(set) var passwordError: String? = nil
        fileprivate(set) var errorMessage: String? = nil
    }
}
