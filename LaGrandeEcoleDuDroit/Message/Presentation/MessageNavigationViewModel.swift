import Combine
import Foundation

class MessageNavigationViewModel: ViewModel {
    private let routeRepository: RouteRepository
    private let navigationRequestUseCase: NavigationRequestUseCase
    
    @Published var path: [MessageRoute] = []
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        routeRepository: RouteRepository,
        navigationRequestUseCase: NavigationRequestUseCase
    ) {
        self.routeRepository = routeRepository
        self.navigationRequestUseCase = navigationRequestUseCase
        listenNavigationRequest()
        listenPathChanges()
    }
    
    private func listenPathChanges() {
        $path.sink { [weak self] path in
            if let route = path.last {
                self?.routeRepository.setCurrentRoute(route)
            } else {
                self?.routeRepository.setCurrentRoute(MessageMainRoute.conversation)
            }
        }.store(in: &cancellables)
    }
    
    private func listenNavigationRequest() {
        navigationRequestUseCase.routeToNavigate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] routeToNavigate in
                let messageRoutes = routeToNavigate.routes.compactMap({ $0 as? MessageRoute })
                if !messageRoutes.isEmpty {
                    self?.path = messageRoutes
                }
                self?.navigationRequestUseCase.resetRoute()
            }.store(in: &cancellables)
    }
}

enum MessageRoute: Route {
    case chat(conversation: Conversation)
    case createConversation
    case interlocutor(user: User)
}

enum MessageMainRoute: MainRoute {
    case conversation
}
