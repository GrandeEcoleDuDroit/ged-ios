import Foundation
import SwiftUI
import Combine

class AccountViewModel: ObservableObject {
    private let userRepository: UserRepository
    private let updateProfilePictureUseCase: UpdateProfilePictureUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var uiState: AccountUiState = AccountUiState()
    @Published var event: SingleUiEvent? = nil
    
    init(
        userRepository: UserRepository,
        updateProfilePictureUseCase: UpdateProfilePictureUseCase
    ) {
        self.userRepository = userRepository
        self.updateProfilePictureUseCase = updateProfilePictureUseCase
        
        initCurrentUser()
    }
    
    func onScreenStateChange(_ state: AccountScreenState) {
        uiState.screenState = state
    }
    
    func updateProfilePicture(imageData: Data?) {
        guard let imageData = imageData else {
            return updateEvent(ErrorEvent(message: "Image data is required."))
        }
        
        DispatchQueue.main.sync { [weak self] in
            self?.uiState.loading = true
        }
        
        Task {
            do {
                try await updateProfilePictureUseCase.execute(imageData: imageData)
                DispatchQueue.main.sync { [weak self] in
                    self?.uiState.loading = true
                    self?.uiState.screenState = .read
                }
            } catch {
                DispatchQueue.main.sync { [weak self] in
                    self?.uiState.loading = false
                }
                updateEvent(ErrorEvent(message: mapNetworkErrorMessage(error)))
            }
        }
    }
    
    private func updateEvent(_ event: SingleUiEvent) {
        DispatchQueue.main.sync { [weak self] in
            self?.event = event
        }
    }
    
    private func initCurrentUser() {
        userRepository.user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.uiState.user = user
            }.store(in: &cancellables)
    }
    
    struct AccountUiState: Withable {
        var user: User? = nil
        var loading: Bool = false
        var screenState: AccountScreenState = .read
    }
}

enum AccountScreenState {
   case edit, read
}
