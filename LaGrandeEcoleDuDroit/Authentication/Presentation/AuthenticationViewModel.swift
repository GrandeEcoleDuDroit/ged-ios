import SwiftUI
import Combine

class AuthenticationViewModel: ViewModel {
    private let loginUseCase: LoginUseCase

    @Published var uiState = AuthenticationUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    
    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }
    
    func login() {
        let (email, password) = (uiState.email, uiState.password)
        guard validateInputs(email: email, password: password) else { return }
        
        performUiBlockingRequest(
            block: { [weak self] in
                try await self?.loginUseCase.execute(email: email, password: password)
            },
            onLoading: { [weak self] in
                self?.uiState.loading = true
            },
            onError: { [weak self] in
                self?.uiState.errorMessage = $0.localizedDescription
                self?.uiState.password = ""
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
        switch email {
            case _ where email.isBlank(): stringResource(.mandatoryFieldError)
            case _ where !VerifyEmailFormatUseCase.execute(email): stringResource(.incorrectEmailFormatError)
            default: nil
        }
    }
    
    private func validatePassword(password: String) -> String? {
        if password.isBlank() {
            stringResource(.mandatoryFieldError)
        } else {
            nil
        }
    }
    
    struct AuthenticationUiState {
        var email: String = ""
        var password: String = ""
        fileprivate(set) var loading: Bool = false
        fileprivate(set) var emailError: String? = nil
        fileprivate(set) var passwordError: String? = nil
        fileprivate(set) var errorMessage: String? = nil
    }
}
