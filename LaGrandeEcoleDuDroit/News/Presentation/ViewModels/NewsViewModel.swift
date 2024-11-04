import SwiftUI
import Combine

class NewsViewModel: ObservableObject {
    @Published var user: User? = nil
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let setCurrentUser: SetCurrentUserUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        getCurrentUserUseCase: GetCurrentUserUseCase,
        setCurrentUser: SetCurrentUserUseCase
    ) {
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.setCurrentUser = setCurrentUser
        
        self.getCurrentUserUseCase.execute()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching user: \(error)")
                }
            }, receiveValue: { [weak self] user in
                self?.user = user
            })
            .store(in: &cancellables)
    }
    
    func save(user: User) {
        setCurrentUser.execute(user: user)
    }
}
