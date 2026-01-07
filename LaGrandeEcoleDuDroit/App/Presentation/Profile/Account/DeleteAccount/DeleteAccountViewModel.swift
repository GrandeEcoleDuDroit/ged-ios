import Foundation
import Combine

class DeleteAccountViewModel: ViewModel {
    private let userRepository: UserRepository
    private let networkMonitor: NetworkMonitor
    private let deleteUserAccountUseCase: DeleteAccountUseCase
    
    @Published var uiState = DeleteAccountUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    
    init(
        userRepository: UserRepository,
        networkMonitor: NetworkMonitor,
        deleteUserAccountUseCase: DeleteAccountUseCase
    ) {
        self.userRepository = userRepository
        self.networkMonitor = networkMonitor
        self.deleteUserAccountUseCase = deleteUserAccountUseCase
    }
    
    func deleteUserAccount() {
        let password = uiState.password
        guard let currentUser = userRepository.currentUser else {
            event = ErrorEvent(message: stringResource(.currentUserNotFoundError))
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
            onError: { [weak self] in
                guard let self else { return }
                self.event = ErrorEvent(message: self.mapErrorMessage($0))
            },
            onFinally: { [weak self] in
                self?.uiState.loading = false
            }
        )
    }
    
    private func mapErrorMessage(_ e: Error) -> String {
        mapNetworkErrorMessage(e) {
            if let authError = e as? AuthenticationError {
                switch authError {
                    case .invalidCredentials: stringResource(.incorrectPasswordError)
                    case .userDisabled: stringResource(.disabledUserError)
                    default: stringResource(.unknownError)
                }
            } else {
                stringResource(.unknownError)
            }
        }
    }
    
    struct DeleteAccountUiState {
        var password: String = ""
        fileprivate(set) var errorMessage: String? = nil
        fileprivate(set) var loading: Bool = false
    }
}
