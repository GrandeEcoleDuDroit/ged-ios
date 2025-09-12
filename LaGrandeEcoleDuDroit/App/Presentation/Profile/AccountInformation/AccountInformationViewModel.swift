import Foundation
import Combine

class AccountInformationViewModel: ObservableObject {
    private let updateProfilePictureUseCase: UpdateProfilePictureUseCase
    private let deleteProfilePictureUseCase: DeleteProfilePictureUseCase
    private let networkMonitor: NetworkMonitor
    private let userRepository: UserRepository
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var uiState: AccountInformationUiState = AccountInformationUiState()
    @Published var event: SingleUiEvent? = nil
    
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
        guard let imageData = imageData else {
            return event = ErrorEvent(message: "Image data is required.")
        }
        
        guard let user = uiState.user else {
            return
        }
        
        uiState.loading = true
        
        Task {  [weak self] in
            do {
                try await self?.updateProfilePictureUseCase.execute(user: user, imageData: imageData)
                DispatchQueue.main.sync { [weak self] in
                    self?.resetValues()
                }
            } catch {
                DispatchQueue.main.sync { [weak self] in
                    self?.resetValues()
                    self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
                }
            }
        }
    }
    
    func deleteProfilePicture() {
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: getString(.noInternetConectionError))
        }
        
        guard let user = uiState.user else {
            return event = ErrorEvent(message: getString(.userNotFoundError))
        }
        
        uiState.loading = true
        
        Task { [weak self] in
            do {
                if let url = user.profilePictureUrl {
                    try await self?.deleteProfilePictureUseCase.execute(userId: user.id, profilePictureUrl: url)
                }
                DispatchQueue.main.sync { [weak self] in
                    self?.resetValues()
                }
            } catch {
                DispatchQueue.main.sync { [weak self] in
                    self?.resetValues()
                    self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
                }
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
