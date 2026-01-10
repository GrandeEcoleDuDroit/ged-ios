import Foundation
import Combine

class DeleteAccountViewModel: ViewModel {
    private let userRepository: UserRepository
    private let deleteUserAccountUseCase: DeleteAccountUseCase
    
    @Published var uiState = DeleteAccountUiState()
    
    init(
        userRepository: UserRepository,
        deleteUserAccountUseCase: DeleteAccountUseCase
    ) {
        self.userRepository = userRepository
        self.deleteUserAccountUseCase = deleteUserAccountUseCase
    }
    
    func deleteUserAccount() {
        let password = uiState.password
        guard let currentUser = userRepository.currentUser else {
            uiState.errorMessage = stringResource(.currentUserNotFoundError)
            return
        }
        guard validateInput(password: password) else { return }
        
        performRequest { [weak self] in
            try await self?.deleteUserAccountUseCase.execute(user: currentUser, password: password)
        }
    }
    
    private func validateInput(password: String) -> Bool {
        uiState.errorMessage = validatePassword(password: password)
        return uiState.errorMessage == nil
    }
    
    private func validatePassword(password: String) -> String? {
        if password.isBlank() {
            stringResource(.emptyInputsError)
        } else {
            nil
        }
    }
    
    private func performRequest(block: @escaping () async throws -> Void) {
        performUiBlockingRequest(
            block: block,
            onLoading: { [weak self] in
                self?.uiState.loading = true
            },
            onError: { [weak self] error in
                var message = error.localizedDescription
                
                if let authError = error as? AuthenticationError, case .invalidCredentials = authError {
                    message = stringResource(.incorrectPasswordError)
                }
                
                self?.uiState.errorMessage = message
            },
            onFinshed: { [weak self] in
                self?.uiState.loading = false
            }
        )
    }
    
    struct DeleteAccountUiState {
        var password: String = ""
        fileprivate(set) var errorMessage: String? = nil
        fileprivate(set) var loading: Bool = false
    }
}
