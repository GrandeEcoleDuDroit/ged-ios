import Combine
import Foundation

class NavigationHostViewModel: ObservableObject {
    private let authenticationRepository: AuthenticationRepository
    @Published var uiState: NavigationHostUiState = NavigationHostUiState()
    private var cancellables: Set<AnyCancellable> = []

    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
        updateStartDestination()
    }
    
    private func updateStartDestination() {
        authenticationRepository.authenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated in
                self?.uiState.startDestination = isAuthenticated ? .app : .authentication
            }.store(in: &cancellables)
    }
    
    struct NavigationHostUiState {
        var startDestination: AppRoute = .splash
    }
    
    enum AppRoute: Route {
        case authentication
        case app
        case splash
    }
}
