import Foundation
import Combine

class DeleteAccountViewModel: ViewModel {
    private let networkMonitor: NetworkMonitor
    private let deleteUserAccountUseCase: DeleteUserAccountUseCase
    
    @Published var uiState = AccountUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    
    init(
        networkMonitor: NetworkMonitor,
        deleteUserAccountUseCase: DeleteUserAccountUseCase
    ) {
        self.networkMonitor = networkMonitor
        self.deleteUserAccountUseCase = deleteUserAccountUseCase
    }
    
    func deleteUserAccount() {
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: getString(.noInternetConectionError))
        }
        
        let (email, password) = (uiState.email, uiState.password)
        
        if let errorMessage = validateInputs(email: email, password: password) {
            uiState.errorMessage = errorMessage
            return
        }
        
        uiState.loading = true
        
        Task { [weak self] in
            do {
                try await self?.deleteUserAccountUseCase.execute(email: email, password: password)
                self?.uiState.loading = false
            } catch {
                self?.uiState.loading = false
                self?.event = ErrorEvent(message: self?.mapErrorMessage(error) ?? getString(.unknownError))
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
        fileprivate(set) var errorMessage: String? = nil
        fileprivate(set) var loading: Bool = false
    }
}
