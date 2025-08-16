protocol RouteRepository {
    var currentRoute: (any Route)? { get }
    
    func setCurrentRoute(_ route: any Route)
}
