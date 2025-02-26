import Combine
import Foundation

class MainViewModel: ObservableObject {
    private let isUserAuthenticatedUseCase: IsUserAuthenticatedUseCase
    @Published private(set) var authenticationState: AuthenticationState = .waiting
    private var cancellables: Set<AnyCancellable> = []
    
    init(isUserAuthenticatedUseCase: IsUserAuthenticatedUseCase) {
        self.isUserAuthenticatedUseCase = isUserAuthenticatedUseCase
        listenAuthenticationState()
    }
    
    private func listenAuthenticationState() {
        isUserAuthenticatedUseCase.execute()
            .receive(on: RunLoop.main)
            .sink { [weak self] isAuthenticated in
                self?.authenticationState = isAuthenticated ? .authenticated : .unauthenticated
            }
            .store(in: &cancellables)
    }
}
