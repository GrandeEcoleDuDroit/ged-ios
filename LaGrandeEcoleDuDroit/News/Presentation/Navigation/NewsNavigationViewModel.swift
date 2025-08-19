class NewsNavigationViewModel {
    private let routeRepository: RouteRepository
    
    init(routeRepository: RouteRepository) {
        self.routeRepository = routeRepository
    }
    
    func setCurrentRoute(_ route: any Route) {
        routeRepository.setCurrentRoute(route)
    }
}
