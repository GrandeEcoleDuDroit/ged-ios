import Foundation
import Combine

class AccountInformationViewModel: ViewModel {
    private let updateProfilePictureUseCase: UpdateProfilePictureUseCase
    private let userRepository: UserRepository

    @Published private(set) var uiState: AccountInformationUiState = AccountInformationUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private var cancellables: Set<AnyCancellable> = []

    init(
        updateProfilePictureUseCase: UpdateProfilePictureUseCase,
        userRepository: UserRepository
    ) {
        self.updateProfilePictureUseCase = updateProfilePictureUseCase
        self.userRepository = userRepository
        
        initCurrentUser()
    }
    
    func updateProfilePicture(imageData: Data?) {
        guard let imageData else {
            event = ErrorEvent(message: "Image not provided.")
            return
        }
        guard let user = uiState.user else {
            event = ErrorEvent(message: stringResource(.currentUserNotFoundError))
            return
        }
        
        performRequest { [weak self] in
            try await self?.updateProfilePictureUseCase.execute(user: user, imageData: imageData)
        }
    }
    
    func deleteProfilePicture() {
        guard let user = uiState.user else {
            event = ErrorEvent(message: stringResource(.currentUserNotFoundError))
            return
        }
        
        performRequest { [weak self] in
            try await self?.userRepository.deleteProfilePicture(user: user)
        }
    }
    
    func onScreenStateChange(_ state: ScreenState) {
        uiState.screenState = state
    }
    
    private func performRequest(block: @escaping () async throws -> Void) {
        performUiBlockingRequest(
            block: block,
            onLoading: { [weak self] in
                self?.uiState.loading = true
            },
            onError: { [weak self] in
                self?.event = ErrorEvent(message: $0.localizedDescription)
            },
            onFinshed: { [weak self] in
                self?.uiState.loading = false
                self?.resetScreenState()
            }
        )
    }
    
    private func initCurrentUser() {
        userRepository.user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.uiState.user = user
            }.store(in: &cancellables)
    }
    
    private func resetScreenState() {
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
