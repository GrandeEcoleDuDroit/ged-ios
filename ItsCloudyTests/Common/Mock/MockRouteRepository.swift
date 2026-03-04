class MockRouteRepository: RouteRepository {
    var currentRoute: (any Route)? { nil }
    
    func setCurrentRoute(_ route: any Route) {}
}
