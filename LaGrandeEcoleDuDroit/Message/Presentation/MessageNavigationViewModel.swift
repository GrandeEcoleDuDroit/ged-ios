import Combine
import Foundation

class MessageNavigationViewModel: ObservableObject {
    private let navigationRequestUseCase: NavigationRequestUseCase
    
    @Published var routesToNavigate: [any Route] = []
    private var cancellables: Set<AnyCancellable> = []

    init(navigationRequestUseCase: NavigationRequestUseCase) {
        self.navigationRequestUseCase = navigationRequestUseCase
    }
    
    private func listenNavigationRequest() {
        navigationRequestUseCase.routesToNavigate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routes in
                self?.routesToNavigate = routes
            }.store(in: &cancellables)
    }
}
