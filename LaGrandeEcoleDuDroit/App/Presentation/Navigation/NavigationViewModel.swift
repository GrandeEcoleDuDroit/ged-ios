import Combine
import Foundation

class NavigationViewModel: ObservableObject {
    private let authenticationRepository: AuthenticationRepository
    private let getUnreadConversationsCountUseCase: GetUnreadConversationsCountUseCase
    private let navigationRequestUseCase: NavigationRequestUseCase
    
    @Published var uiState: NavigationUiState = NavigationUiState()
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        authenticationRepository: AuthenticationRepository,
        getUnreadConversationsCountUseCase: GetUnreadConversationsCountUseCase,
        navigationRequestUseCase: NavigationRequestUseCase
    ) {
        self.authenticationRepository = authenticationRepository
        self.getUnreadConversationsCountUseCase = getUnreadConversationsCountUseCase
        self.navigationRequestUseCase = navigationRequestUseCase
        
        updateStartDestination()
        updateMessagesBadges()
        listenNavigationRequest()
    }
    
    private func updateStartDestination() {
        authenticationRepository.authenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated in
                self?.uiState.startDestination = isAuthenticated ? .app : .authentication
            }.store(in: &cancellables)
    }
    
    private func updateMessagesBadges() {
        getUnreadConversationsCountUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] number in
                self?.uiState.badges[.message] = number
            }.store(in: &cancellables)
    }
    
    private func listenNavigationRequest() {
        navigationRequestUseCase.routesToNavigate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routes in
                self?.uiState.routesToNavigate = routes
            }.store(in: &cancellables)

    }
    
    struct NavigationUiState {
        var startDestination: AppRoute = .splash
        var badges: [TopLevelDestination: Int] = [:]
        var routesToNavigate: [any Route] = []
    }
    
    enum AppRoute: Route {
        case authentication
        case app
        case splash
    }
}
