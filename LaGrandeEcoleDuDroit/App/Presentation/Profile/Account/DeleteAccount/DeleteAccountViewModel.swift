import Foundation
import Combine

class DeleteAccountViewModel: ObservableObject {
    private let networkMonitor: NetworkMonitor
    private let deleteUserAccountUseCase: DeleteUserAccountUseCase
    
    @Published var uiState = AccountUiState()
    @Published var event: SingleUiEvent? = nil
    
    init(
        networkMonitor: NetworkMonitor,
        deleteUserAccountUseCase: DeleteUserAccountUseCase
    ) {
        self.networkMonitor = networkMonitor
        self.deleteUserAccountUseCase = deleteUserAccountUseCase
    }
    
    func deleteUserAccount() {
        let (email, password) = (uiState.email, uiState.password)
        
        if let errorMessage = validateInputs(email: email, password: password) {
            uiState.errorMessage = errorMessage
            return
        }
        
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: getString(.noInternetConectionError))
        }
        
        uiState.loading = true
        
        Task {
            do {
                try await deleteUserAccountUseCase.execute(email: email, password: password)
                DispatchQueue.main.sync { [weak self] in
                    self?.uiState.loading = false
                }
            } catch {
                DispatchQueue.main.sync { [weak self] in
                    self?.uiState.loading = false
                    self?.event = ErrorEvent(message: self?.mapErrorMessage(error) ?? getString(.unknownError))
                }
            }
        }
    }
    
    private func validateInputs(email: String, password: String) -> String? {
        if let emailError = validateEmail(email: email) {
            return emailError
        }
        
        if let passwordError = validatePassword(password: password) {
            return passwordError
        }
        
        return nil
    }
    
    private func validateEmail(email: String) -> String? {
        if email.isBlank {
            getString(.emptyInputsError)
        } else if !VerifyEmailFormatUseCase.execute(email) {
            getString(.invalidEmailError)
        } else {
            nil
        }
    }
    
    private func validatePassword(password: String) -> String? {
        if password.isBlank {
            getString(.emptyInputsError)
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
    
    struct AccountUiState {
        var email: String = ""
        var password: String = ""
        var errorMessage: String? = nil
        var loading: Bool = false
    }
}
