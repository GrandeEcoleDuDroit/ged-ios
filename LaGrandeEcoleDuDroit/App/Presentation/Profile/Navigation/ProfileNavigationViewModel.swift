import Foundation
import Combine

class ProfileNavigationViewModel: ViewModel {
    private let routeRepository: RouteRepository
    
    @Published var path: [ProfileRoute] = []
    private var cancellables: Set<AnyCancellable> = []
    
    init(routeRepository: RouteRepository) {
        self.routeRepository = routeRepository
    }

    private func listenPathChanges() {
        $path.sink { [weak self] path in
            if let route = path.last {
                self?.routeRepository.setCurrentRoute(route)
            } else {
                self?.routeRepository.setCurrentRoute(ProfileMainRoute.profile)
            }
        }.store(in: &cancellables)
    }
}

enum ProfileRoute: Route {
    case accountInfos
    case account
    case deleteAccount
    case privacy
    case blockedUsers
    case user(User)
}

enum ProfileMainRoute: MainRoute {
    case profile
}
