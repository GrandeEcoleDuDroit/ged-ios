class RouteRepositoryImpl: RouteRepository {
    private(set) var currentRoute: (any Route)? = nil
    
    func setCurrentRoute(_ route: any Route) {
        currentRoute = route
    }
}
