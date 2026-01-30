import Combine

class ForgottenPasswordViewModel: ViewModel {
    private let authenticationRepository: AuthenticationRepository
    
    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
    }
    
    @Published var uiState = ForgottenPasswordUiState()
    
    func resetEmail() {
        let email = uiState.email
        guard validateInput(email: email) else { return }
        
        performUiBlockingRequest(
            block: { [weak self] in
                try await self?.authenticationRepository.resetPassword(email: email)
                self?.uiState.successMessage = stringResource(.forgottenPasswordSuccessMessage)
            },
            onLoading: { [weak self] in
                self?.uiState.loading = true
            },
            onError: { [weak self] in
                self?.uiState.errorMessage = $0.localizedDescription
            },
            onFinshed: { [weak self] in
                self?.uiState.loading = false
            }
        )
    }
    
    private func validateInput(email: String) -> Bool {
        uiState.emailError = validateEmail(email: email)
        return uiState.emailError == nil
    }
    
    private func validateEmail(email: String) -> String? {
        switch email {
            case _ where email.isBlank(): stringResource(.mandatoryFieldError)
            case _ where !VerifyEmailFormatUseCase.execute(email): stringResource(.incorrectEmailFormatError)
            default: nil
        }
    }
    
    struct ForgottenPasswordUiState {
        var email: String = ""
        fileprivate(set) var loading: Bool = false
        fileprivate(set) var emailError: String? = nil
        fileprivate(set) var errorMessage: String? = nil
        fileprivate(set) var successMessage: String? = nil
    }
}
