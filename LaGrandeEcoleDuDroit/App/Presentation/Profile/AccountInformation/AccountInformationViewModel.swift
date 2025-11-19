import Foundation
import Combine

class AccountInformationViewModel: ViewModel {
    private let updateProfilePictureUseCase: UpdateProfilePictureUseCase
    private let deleteProfilePictureUseCase: DeleteProfilePictureUseCase
    private let networkMonitor: NetworkMonitor
    private let userRepository: UserRepository

    @Published private(set) var uiState: AccountInformationUiState = AccountInformationUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private var cancellables: Set<AnyCancellable> = []

    init(
        updateProfilePictureUseCase: UpdateProfilePictureUseCase,
        deleteProfilePictureUseCase: DeleteProfilePictureUseCase,
        networkMonitor: NetworkMonitor,
        userRepository: UserRepository
    ) {
        self.updateProfilePictureUseCase = updateProfilePictureUseCase
        self.deleteProfilePictureUseCase = deleteProfilePictureUseCase
        self.networkMonitor = networkMonitor
        self.userRepository = userRepository
        
        initCurrentUser()
    }
    
    func updateProfilePicture(imageData: Data?) {
        guard let imageData else {
            return event = ErrorEvent(message: "Image data is required.")
        }
        guard let user = uiState.user else { return }
        
        uiState.loading = true
        
        Task { @MainActor [weak self] in
            do {
                try await self?.updateProfilePictureUseCase.execute(user: user, imageData: imageData)
                self?.resetValues()
            } catch {
                self?.resetValues()
                self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
            }
        }
    }
    
    func deleteProfilePicture() {
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: stringResource(.noInternetConectionError))
        }
        guard let currentUser = uiState.user else {
            return event = ErrorEvent(message: stringResource(.currentUserNotFoundError))
        }
        
        uiState.loading = true
        
        Task { @MainActor [weak self] in
            do {
                if let url = currentUser.profilePictureUrl {
                    try await self?.deleteProfilePictureUseCase.execute(
                        userId: currentUser.id,
                        profilePictureUrl: url
                    )
                }
                self?.resetValues()
            } catch {
                self?.resetValues()
                self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
            }
        }
    }
    
    func onScreenStateChange(_ state: ScreenState) {
        uiState.screenState = state
    }
    
    private func initCurrentUser() {
        userRepository.user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.uiState.user = user
            }.store(in: &cancellables)
    }
    
    private func resetValues() {
        uiState.screenState = .read
        uiState.loading = false
    }
    
    struct AccountInformationUiState {
        var user: User? = nil
        var loading: Bool = false
        var screenState: ScreenState = .read
    }
    
    enum ScreenState {
        case edit, read
    }
}
