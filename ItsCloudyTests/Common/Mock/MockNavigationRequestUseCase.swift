import Combine

class MockNavigationRequestUseCase: NavigationRequestUseCase {
    override var routeToNavigate: AnyPublisher<RouteToNavigate, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    override func navigate(to routeToNavigate: RouteToNavigate) {}
    
    override func resetRoute() {}
}
