import Foundation
import Combine

class DeleteAccountViewModel: ViewModel {
    private let userRepository: UserRepository
    private let networkMonitor: NetworkMonitor
    private let deleteUserAccountUseCase: DeleteUserAccountUseCase
    
    @Published var uiState = DeleteAccountUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    
    init(
        userRepository: UserRepository,
        networkMonitor: NetworkMonitor,
        deleteUserAccountUseCase: DeleteUserAccountUseCase
    ) {
        self.userRepository = userRepository
        self.networkMonitor = networkMonitor
        self.deleteUserAccountUseCase = deleteUserAccountUseCase
    }
    
    func deleteUserAccount() {
        guard let email = userRepository.currentUser?.email else {
            return 
        }
        let password = uiState.password
        
        guard validateInput(password: password) else {
            return
        }
        
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: getString(.noInternetConectionError))
        }
        
        uiState.loading = true
        
        Task { @MainActor [weak self] in
            do {
                try await self?.deleteUserAccountUseCase.execute(email: email, password: password)
                self?.uiState.loading = false
            } catch {
                self?.uiState.loading = false
                self?.uiState.errorMessage = self?.mapErrorMessage(error)
            }
        }
    }
    
    private func validateInput(password: String) -> Bool {
        uiState.errorMessage = validatePassword(password: password)
        return uiState.errorMessage == nil
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
                    case .invalidCredentials: getString(.incorrectPasswordError)
                    case .userDisabled: getString(.userDisabledError)
                    default: getString(.unknownError)
                }
            } else {
                getString(.unknownError)
            }
        }
    }
    
    struct DeleteAccountUiState {
        var password: String = ""
        fileprivate(set) var errorMessage: String? = nil
        fileprivate(set) var loading: Bool = false
    }
}
