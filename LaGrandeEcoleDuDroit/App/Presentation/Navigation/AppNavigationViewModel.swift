import Combine
import Foundation

class AppNavigationViewModel: ViewModel {
    private let getUnreadConversationsCountUseCase: GetUnreadConversationsCountUseCase
    private let navigationRequestUseCase: NavigationRequestUseCase

    @Published private(set) var uiState: AppNavigationUiState = AppNavigationUiState()
    @Published private(set) var tabToNavigate: TopLevelDestination? = nil
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        getUnreadConversationsCountUseCase: GetUnreadConversationsCountUseCase,
        navigationRequestUseCase: NavigationRequestUseCase
    ) {
        self.getUnreadConversationsCountUseCase = getUnreadConversationsCountUseCase
        self.navigationRequestUseCase = navigationRequestUseCase
        
        updateMessagesBadges()
        listenNavigationRequest()
    }
        
    private func updateMessagesBadges() {
        getUnreadConversationsCountUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] number in
                self?.uiState.badges[.message] = number
            }.store(in: &cancellables)
    }
    
    private func listenNavigationRequest() {
        navigationRequestUseCase.routeToNavigate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routeToNavigate in
                self?.tabToNavigate = self?.mapToTopLevelDestination(routeToNavigate)
            }.store(in: &cancellables)

    }
    
    private func mapToTopLevelDestination(_ routeToNavigate: RouteToNavigate) -> TopLevelDestination? {
        switch routeToNavigate.mainRoute {
            case is NewsMainRoute: .home
            case is MessageMainRoute: .message
            case is ProfileMainRoute: .profile
            default: nil
        }
    }
    
    struct AppNavigationUiState {
        var badges: [TopLevelDestination: Int] = [:]
    }
}
