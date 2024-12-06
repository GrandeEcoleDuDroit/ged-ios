import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published private(set) var currentUser: User? = nil
    @Published private var profileState: ProfileState = .idle
    
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private var cancellables: Set<AnyCancellable> = []
    private let logoutUseCase: LogoutUseCase
    
    let menuItemDatas: [MenuItemData] = [
        MenuItemData(
            name: MenuItemData.Name.account,
            imageName: "person.fill",
            title: getString(gedString: GedString.account)
        )
    ]
    
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
            profileState = .error(message: GedString.error_logout)
            print("Error logging out: \(error)")
        }
    }
    
    private func initCurrentUser() {
        getCurrentUserUseCase.executeWithPublisher()
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
