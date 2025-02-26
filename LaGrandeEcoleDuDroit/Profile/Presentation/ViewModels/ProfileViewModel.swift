import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published private(set) var currentUser: User? = nil
    @Published private var screenState: ProfileScreenState = .idle
    
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
        do {
            try logoutUseCase.execute()
        } catch {
            screenState = .error(message: getString(.errorLogout))
            print("Error logging out: \(error)")
        }
    }
    
    private func initCurrentUser() {
        getCurrentUserUseCase.execute()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error fetching user: \(error)")
                }
            }, receiveValue: { [weak self] user in
                self?.currentUser = user
            })
            .store(in: &cancellables)
    }
}
