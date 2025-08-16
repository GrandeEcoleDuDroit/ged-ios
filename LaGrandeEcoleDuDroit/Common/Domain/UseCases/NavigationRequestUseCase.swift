import Combine

class NavigationRequestUseCase {
    private var routeToNavigateSubject = PassthroughSubject<any Route, Never>()
    var routeToNavigate: AnyPublisher<any Route, Never> {
        routeToNavigateSubject.eraseToAnyPublisher()
    }
    
    func navigate(to route: any Route) {
        routeToNavigateSubject.send(route)
    }
}
