import Combine
import Foundation

class MessageNavigationViewModel: ViewModel {
    private let routeRepository: RouteRepository
    private let navigationRequestUseCase: NavigationRequestUseCase
    
    @Published fileprivate(set) var routeToNavigate: RouteToNavigate?
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        routeRepository: RouteRepository,
        navigationRequestUseCase: NavigationRequestUseCase
    ) {
        self.routeRepository = routeRepository
        self.navigationRequestUseCase = navigationRequestUseCase
        listenNavigationRequest()
    }

    func setCurrentRoute(_ route: any Route) {
        routeRepository.setCurrentRoute(route)
    }
    
    private func listenNavigationRequest() {
        navigationRequestUseCase.routeToNavigate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routeToNavigate in
                self?.routeToNavigate = routeToNavigate
                self?.navigationRequestUseCase.resetRoute()
            }.store(in: &cancellables)
    }
}
