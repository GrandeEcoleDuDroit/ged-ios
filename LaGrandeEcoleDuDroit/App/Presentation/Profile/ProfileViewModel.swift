import Combine
import Foundation

class ProfileViewModel: ObservableObject {
    private let userRepository: UserRepository
    private let authenticationRepository: AuthenticationRepository
    private let loadImageUseCase: LoadImageUseCase
    private var cancellables: Set<AnyCancellable> = []

    @Published var uiState: ProfileUiState = ProfileUiState()

    init(
        userRepository: UserRepository,
        authenticationRepository: AuthenticationRepository,
        loadImageUseCase: LoadImageUseCase
    ) {
        self.userRepository = userRepository
        self.authenticationRepository = authenticationRepository
        self.loadImageUseCase = loadImageUseCase

        initUser()
    }
    
    func refreshUserImageIfNecessary() {
        guard let profilePictureUrl = uiState.user?.profilePictureUrl else {
            uiState.user = uiState.user?.with(imagePhase: .empty)
            return
        }
        
        if uiState.user?.imagePhase == .failure {
            loadUserImage(url: profilePictureUrl)
        }
    }

    func logout() {
        uiState.loading = true
        authenticationRepository.logout()
    }

    private func initUser() {
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

    struct ProfileUiState {
        var user: User? = nil
        var loading: Bool = false
    }
}
