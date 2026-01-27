import Combine
import Foundation

class NavigationHostViewModel: ViewModel {
    private let authenticationRepository: AuthenticationRepository
    
    @Published private(set) var uiState = NavigationHostUiState()
    private var cancellables: Set<AnyCancellable> = []

    init(authenticationRepository: AuthenticationRepository) {
        self.authenticationRepository = authenticationRepository
        updateStartDestination()
    }
    
    private func updateStartDestination() {
        authenticationRepository.authenticationState
            .receive(on: DispatchQueue.main)
            .map { state in
                switch state {
                    case .authenticated: AppRoute.app
                    case .unauthenticated: AppRoute.authentication
                }
            }
            .sink { [weak self] route in
                self?.uiState.startDestination = route
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
