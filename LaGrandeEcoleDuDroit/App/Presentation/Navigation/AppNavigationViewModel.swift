import Combine
import Foundation

class AppNavigationViewModel: ViewModel {
    private let getUnreadConversationsCountUseCase: GetUnreadConversationsCountUseCase
    private let navigationRequestUseCase: NavigationRequestUseCase

    @Published private(set) var uiState = AppNavigationUiState()
    @Published var selectedTab: TopLevelDestination = .home
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
                if let tab = self?.mapToTopLevelDestination(routeToNavigate) {
                    self?.selectedTab = tab
                }
            }.store(in: &cancellables)

    }
    
    private func mapToTopLevelDestination(_ routeToNavigate: RouteToNavigate) -> TopLevelDestination? {
        switch routeToNavigate.mainRoute {
            case is NewsMainRoute: .home
            case is MessageMainRoute: .message
            case is MissionMainRoute: .mission
            case is ProfileMainRoute: .profile
            default: nil
        }
    }
    
    struct AppNavigationUiState {
        fileprivate(set) var topLevelDestinations: [TopLevelDestination] = [.home, .message, .mission, .profile]
        fileprivate(set) var badges: [TopLevelDestination: Int] = [:]
    }
}
