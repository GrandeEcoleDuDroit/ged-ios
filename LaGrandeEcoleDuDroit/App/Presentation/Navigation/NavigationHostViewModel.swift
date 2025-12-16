import Combine
import Foundation

class NavigationHostViewModel: ViewModel {
    private let listenAuthenticationStateUseCase: ListenAuthenticationStateUseCase
    
    @Published private(set) var uiState = NavigationHostUiState()
    private var cancellables: Set<AnyCancellable> = []

    init(listenAuthenticationStateUseCase: ListenAuthenticationStateUseCase) {
        self.listenAuthenticationStateUseCase = listenAuthenticationStateUseCase
        updateStartDestination()
    }
    
    private func updateStartDestination() {
        listenAuthenticationStateUseCase.authenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] authenticated in
                self?.uiState.startDestination = authenticated ? .app : .authentication
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
