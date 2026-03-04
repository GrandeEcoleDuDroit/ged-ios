import Foundation
import Combine

class NewsNavigationViewModel: ViewModel {
    private let routeRepository: RouteRepository
    
    @Published var path: [NewsRoute] = []
    private var cancellables: Set<AnyCancellable> = []
    
    init(routeRepository: RouteRepository) {
        self.routeRepository = routeRepository
    }
    
    private func listenPathChanges() {
        $path.sink { [weak self] path in
            if let route = path.last {
                self?.routeRepository.setCurrentRoute(route)
            } else {
                self?.routeRepository.setCurrentRoute(NewsMainRoute.news)
            }
        }.store(in: &cancellables)
    }
}

enum NewsRoute: Route {
    case readAnnouncement(announcementId: String)
    case authorProfile(user: User)
    case allAnnouncements
}

enum NewsMainRoute: MainRoute {
    case news
}
