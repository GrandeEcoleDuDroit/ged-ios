import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published private(set) var currentUser: User? = nil
    @Published private var profileState: ProfileState = .idle
    
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private var cancellables: Set<AnyCancellable> = []
    private let logoutUseCase: LogoutUseCase
    
    init(
        getCurrentUserUseCase: GetCurrentUserUseCase,
        logoutUseCase: LogoutUseCase
    ) {
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.logoutUseCase = logoutUseCase
        
        initCurrentUser()
    }
    
    func logout() {
        Task { await logoutUseCase.execute() }
    }
    
    private func initCurrentUser() {
        getCurrentUserUseCase.executeWithPublisher()
            .receive(on: RunLoop.main)
            .sink { [weak self] user in
                self?.currentUser = user
            }
            .store(in: &cancellables)
    }
}
