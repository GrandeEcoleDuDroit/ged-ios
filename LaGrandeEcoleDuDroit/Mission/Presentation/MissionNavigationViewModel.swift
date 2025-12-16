import Foundation
import Combine

class MissionNavigationViewModel: ViewModel {
    private let routeRepository: RouteRepository
    
    @Published var path: [MissionRoute] = []
    private var cancellables: Set<AnyCancellable> = []
    
    init(routeRepository: RouteRepository) {
        self.routeRepository = routeRepository
    }
    
    private func listenPathChanges() {
        $path.sink { [weak self] path in
            if let route = path.last {
                self?.routeRepository.setCurrentRoute(route)
            } else {
                self?.routeRepository.setCurrentRoute(MissionMainRoute.mission)
            }
        }.store(in: &cancellables)
    }
}

enum MissionRoute: Route {
    case createMission
    case editMission(mission: Mission)
    case missionDetails(missionId: String)
    case userProfile(user: User)
}

enum MissionMainRoute: MainRoute {
    case mission
}
