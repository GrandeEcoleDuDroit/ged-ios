import Foundation
import Combine

class ProfileViewModel: ViewModel {
    private let userRepository: UserRepository
    private let authenticationRepository: AuthenticationRepository
    
    @Published private(set) var uiState: ProfileUiState = ProfileUiState()
    private var cancellables: Set<AnyCancellable> = []

    init(
        userRepository: UserRepository,
        authenticationRepository: AuthenticationRepository
    ) {
        self.userRepository = userRepository
        self.authenticationRepository = authenticationRepository
        initUser()
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
            }.store(in: &cancellables)
    }
    
    struct ProfileUiState {
        var user: User? = nil
        var loading: Bool = false
    }
}
