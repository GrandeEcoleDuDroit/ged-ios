import Combine

open class NavigationRequestUseCase {
    private var routeToNavigateSubject = CurrentValueSubject<RouteToNavigate?, Never>(nil)
    var routeToNavigate: AnyPublisher<RouteToNavigate, Never> {
        routeToNavigateSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    func navigate(to routeToNavigate: RouteToNavigate) {
        routeToNavigateSubject.send(routeToNavigate)
    }
    
    func resetRoute() {
        routeToNavigateSubject.send(nil)
    }
}
