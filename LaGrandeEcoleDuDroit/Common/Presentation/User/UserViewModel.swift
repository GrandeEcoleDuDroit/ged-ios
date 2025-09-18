import Combine
import Foundation

class UserViewModel: ObservableObject {
    private let userRepository: UserRepository
    private let networkMonitor: NetworkMonitor
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var uiState: UserUiState = UserUiState()
    @Published var event: SingleUiEvent? = nil
    
    init(
        userRepository: UserRepository,
        networkMonitor: NetworkMonitor
    ) {
        self.userRepository = userRepository
        self.networkMonitor = networkMonitor
        initCurrentUser()
    }
    
    func reportUser(report: UserReport) {
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: getString(.noInternetConectionError))
        }
        
        uiState.loading = true

        Task {
            do {
                try await userRepository.reportUser(report: report)
                DispatchQueue.main.sync { [weak self] in
                    self?.uiState.loading = false
                }
            } catch {
                DispatchQueue.main.sync { [weak self] in
                    self?.uiState.loading = false
                    self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
                }
            }
        }
    }
    
    private func initCurrentUser() {
        userRepository.user.sink { [weak self] user in
            self?.uiState.currentUser = user
        }
        .store(in: &cancellables)
    }
    
    struct UserUiState {
        var currentUser: User? = nil
        var loading: Bool = false
    }
}
