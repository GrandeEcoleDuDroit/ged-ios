import Combine

class MockNavigationRequestUseCase: NavigationRequestUseCase {
    override var routeToNavigate: AnyPublisher<RouteToNavigate, Never> {
        Empty().eraseToAnyPublisher()
    }
}
