import Combine
import Foundation

class NavigationHostViewModel: ObservableObject {
    private let listenAuthenticationStateUseCase: ListenAuthenticationStateUseCase
    @Published var uiState: NavigationHostUiState = NavigationHostUiState()
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
