import Combine
import Foundation
import SwiftUI

class AccountViewModel: ObservableObject {
    private let updateProfilePictureUseCase: UpdateProfilePictureUseCase
    private let deleteProfilePictureUseCase: DeleteProfilePictureUseCase
    private let loadImageUseCase: LoadImageUseCase
    private let networkMonitor: NetworkMonitor
    private let userRepository: UserRepository
    private var cancellables: Set<AnyCancellable> = []

    @Published var uiState: AccountUiState = AccountUiState()
    @Published var event: SingleUiEvent? = nil

    init(
        updateProfilePictureUseCase: UpdateProfilePictureUseCase,
        deleteProfilePictureUseCase: DeleteProfilePictureUseCase,
        loadImageUseCase: LoadImageUseCase,
        networkMonitor: NetworkMonitor,
        userRepository: UserRepository
    ) {
        self.updateProfilePictureUseCase = updateProfilePictureUseCase
        self.deleteProfilePictureUseCase = deleteProfilePictureUseCase
        self.loadImageUseCase = loadImageUseCase
        self.networkMonitor = networkMonitor
        self.userRepository = userRepository

        initCurrentUser()
    }
    
    private func initCurrentUser() {
        userRepository.user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.uiState.user = user
                if let profilePictureUrl = user.profilePictureUrl {
                    self?.loadUserImage(url: profilePictureUrl)
                } else {
                    self?.uiState.user = self?.uiState.user?.with(imagePhase: .empty)
                }
            }.store(in: &cancellables)
    }

    private func loadUserImage(url: String) {
        uiState.user = uiState.user?.with(imagePhase: .loading)
        Task {
            let phase = await loadImageUseCase.execute(url: url)
            DispatchQueue.main.sync { [weak self] in
                self?.uiState.user = self?.uiState.user?.with(imagePhase: phase)
            }
        }
    }

    func updateProfilePicture(imageData: Data?) {
        guard let imageData = imageData else {
            event = ErrorEvent(message: "Image data is required.")
            return
        }

        guard let user = uiState.user else {
            return
        }

        uiState.loading = true

        Task { [weak self] in
            do {
                try await self?.updateProfilePictureUseCase.execute(
                    user: user,
                    imageData: imageData
                )
                DispatchQueue.main.sync { [weak self] in
                    self?.resetValues()
                }
            } catch {
                DispatchQueue.main.sync { [weak self] in
                    self?.resetValues()
                    self?.event = ErrorEvent(
                        message: mapNetworkErrorMessage(error)
                    )
                }
            }
        }
    }

    func deleteProfilePicture() {
        guard networkMonitor.isConnected else {
            event = ErrorEvent(message: getString(.noInternetConectionError))
            return
        }

        guard let user = uiState.user else {
            event = ErrorEvent(message: getString(.userNotFoundError))
            return
        }

        uiState.loading = true

        Task { [weak self] in
            do {
                if let url = user.profilePictureUrl {
                    try await self?.deleteProfilePictureUseCase.execute(
                        userId: user.id,
                        profilePictureUrl: url
                    )
                }
                DispatchQueue.main.sync { [weak self] in
                    self?.resetValues()
                }
            } catch {
                DispatchQueue.main.sync { [weak self] in
                    self?.resetValues()
                    self?.event = ErrorEvent(
                        message: mapNetworkErrorMessage(error)
                    )
                }
            }
        }
    }

    func onScreenStateChange(_ state: AccountScreenState) {
        uiState.screenState = state
    }

    private func resetValues() {
        uiState.screenState = .read
        uiState.loading = false
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
