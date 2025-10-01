import Combine
import Foundation

class NavigationHostViewModel: ViewModel {
    private let listenAuthenticationStateUseCase: ListenAuthenticationStateUseCase
    
    @Published private(set) var uiState: NavigationHostUiState = NavigationHostUiState()
    private var cancellables: Set<AnyCancellable> = []

    init(listenAuthenticationStateUseCase: ListenAuthenticationStateUseCase) {
        self.listenAuthenticationStateUseCase = listenAuthenticationStateUseCase
        updateStartDestination()
    }
    
    private func updateStartDestination() {
        listenAuthenticationStateUseCase.authenticated
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
