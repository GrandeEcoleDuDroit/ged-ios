import Foundation
import Combine

class ProfileViewModel: ViewModel {
    private let userRepository: UserRepository
    private let logoutUseCase: LogoutUseCase
    
    @Published private(set) var uiState: ProfileUiState = ProfileUiState()
    @Published var event: SingleUiEvent?
    private var cancellables: Set<AnyCancellable> = []

    init(
        userRepository: UserRepository,
        logoutUseCase: LogoutUseCase
    ) {
        self.userRepository = userRepository
        self.logoutUseCase = logoutUseCase
        initUser()
    }
    
    func logout() {
        uiState.loading = true
        Task { @MainActor [weak self] in
            do {
                try await self?.logoutUseCase.execute()
            } catch {
                self?.uiState.loading = false
                self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
            }
        }
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
