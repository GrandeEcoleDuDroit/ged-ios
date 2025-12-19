import SwiftUI
import Combine

class AuthenticationViewModel: ViewModel {
    private let loginUseCase: LoginUseCase
    private let networkMonitor: NetworkMonitor
    private var cancellables: Set<AnyCancellable> = []

    @Published var uiState = AuthenticationUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    
    init(
        loginUseCase: LoginUseCase,
        networkMonitor: NetworkMonitor
    ) {
        self.loginUseCase = loginUseCase
        self.networkMonitor = networkMonitor
    }
    
    func login() {
        let (email, password) = (uiState.email, uiState.password)
        guard validateInputs(email: email, password: password) else { return }
        
        guard networkMonitor.isConnected else {
            event = ErrorEvent(message: stringResource(.noInternetConectionError))
            return
        }
        
        uiState.loading = true
        
        Task { @MainActor [weak self] in
            do {
                try await self?.loginUseCase.execute(email: email, password: password)
            } catch {
                self?.uiState.loading = false
                self?.uiState.errorMessage = self?.mapErrorMessage(error)
                self?.uiState.password = ""
            }
        }
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
            default : nil
        }
    }
    
    private func validatePassword(password: String) -> String? {
        if password.isBlank() {
            stringResource(.mandatoryFieldError)
        } else {
            nil
        }
    }
    
    private func mapErrorMessage(_ e: Error) -> String {
        mapNetworkErrorMessage(e) {
            if let authError = e as? AuthenticationError {
                switch authError {
                    case .invalidCredentials: stringResource(.incorrectCredentialsError)
                    case .userDisabled: stringResource(.disabledUserError)
                    default: stringResource(.unknownError)
                }
            } else {
                stringResource(.unknownError)
            }
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
