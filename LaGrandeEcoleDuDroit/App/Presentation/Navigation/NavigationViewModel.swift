import Combine
import Foundation

class NavigationViewModel: ObservableObject {
    private let authenticationRepository: AuthenticationRepository
    private let getUnreadConversationsCountUseCase: GetUnreadConversationsCountUseCase
    @Published var uiState: NavigationUiState = NavigationUiState()
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        authenticationRepository: AuthenticationRepository,
        getUnreadConversationsCountUseCase: GetUnreadConversationsCountUseCase
    ) {
        self.authenticationRepository = authenticationRepository
        self.getUnreadConversationsCountUseCase = getUnreadConversationsCountUseCase
        updateStartDestination()
        updateMessagesBadges()
    }
    
    private func updateStartDestination() {
        authenticationRepository.authenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated in
                self?.uiState.startDestination = isAuthenticated ? .home : .authentication
            }.store(in: &cancellables)
    }
    
    private func updateMessagesBadges() {
        getUnreadConversationsCountUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] number in
                self?.uiState.badges[.message] = number
            }.store(in: &cancellables)
    }
    
    struct NavigationUiState {
        var startDestination: Route = .splash
        var badges: [TopLevelDestination: Int] = [:]
    }
    
    enum Route {
        case authentication
        case home
        case splash
    }
}
