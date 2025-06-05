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
                guard let self = self else { return }
                self.uiState.topLevelDestinations = self.uiState.topLevelDestinations
                    .map { destination in
                        switch destination {
                            case .message: .message(badges: number)
                            default: destination
                        }
                    }
            }.store(in: &cancellables)
    }
    
    struct NavigationUiState {
        var startDestination: Route = .splash
        var topLevelDestinations: [TopLevelDestination] = [.home, .message(), .profile]
    }
    
    enum Route {
        case authentication
        case home
        case splash
    }
}
