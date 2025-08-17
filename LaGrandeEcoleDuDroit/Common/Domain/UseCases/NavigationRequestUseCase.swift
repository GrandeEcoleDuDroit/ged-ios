import Combine

class NavigationRequestUseCase {
    private var routesToNavigateSubject = PassthroughSubject<[any Route], Never>()
    var routesToNavigate: AnyPublisher<[any Route], Never> {
        routesToNavigateSubject.eraseToAnyPublisher()
    }
    
    func navigate(to routes: [any Route]) {
        routesToNavigateSubject.send(routes)
    }
}
