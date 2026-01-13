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
        performRequest { [weak self] in
            try await self?.logoutUseCase.execute()
        }
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
            }
        )
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
