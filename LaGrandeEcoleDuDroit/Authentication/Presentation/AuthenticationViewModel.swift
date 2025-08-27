import SwiftUI
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var uiState: AuthenticationUiState = AuthenticationUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    
    private var cancellables: Set<AnyCancellable> = []
    private let loginUseCase: LoginUseCase
    
    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }
    
    func login() {
        let (email, password) = (uiState.email, uiState.password)
        guard validateInputs(email: email, password: password) else { return }
        uiState.loading = true
        
        Task {
            do {
                try await loginUseCase.execute(email: email, password: password)
            }
            catch let error as RequestError {
                DispatchQueue.main.sync { [weak self] in
                    self?.uiState.loading = false
                    switch error {
                        case .noInternetConnection: self?.event = ErrorEvent(message: getString(.noInternetConectionError))
                        default: self?.uiState.errorMessage = self?.mapErrorMessage(error)
                    }
                    self?.uiState.password = ""
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
    
    private func validateInputs(email: String, password: String) -> Bool {
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
        } else {
            nil
        }
    }
    
    private func mapErrorMessage(_ e: Error) -> String {
        mapNetworkErrorMessage(e) {
            if let authError = e as? AuthenticationError {
                switch authError {
                    case .invalidCredentials: getString(.invalidCredentials)
                    case .userDisabled: getString(.userDisabled)
                    default: getString(.unknownError)
                }
            } else {
                getString(.unknownError)
            }
        }
    }
    
    struct AuthenticationUiState {
        var email: String = ""
        var password: String = ""
        var emailError: String? = nil
        var passwordError: String? = nil
        var errorMessage: String? = nil
        var loading: Bool = false
    }
}
