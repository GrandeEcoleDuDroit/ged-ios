import Foundation
import SwiftUI
import Combine

class AccountViewModel: ObservableObject {
    @Published private(set) var currentUser: User? = nil
    @Published private(set) var screenState: AccountScreenState = .initial
    
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let updateProfilePictureUseCase: UpdateProfilePictureUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        getCurrentUserUseCase: GetCurrentUserUseCase,
        updateProfilePictureUseCase: UpdateProfilePictureUseCase
    ) {
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.updateProfilePictureUseCase = updateProfilePictureUseCase
        
        initCurrentUser()
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
    
    func updateProfilePicture(imageData: Data?) {
        guard let imageData = imageData else {
            screenState = .error(message: "Image data is nil")
            return
        }
        
        screenState = .loading
        Task {
            do {
                try await updateProfilePictureUseCase.execute(imageData: imageData)
                updateScreenState(.success)
            } catch {
                updateScreenState(.error(message: error.localizedDescription))
            }
        }
    }
    
    func updateScreenState(_ screenState: AccountScreenState) {
        DispatchQueue.main.async { [weak self] in
            self?.screenState = screenState
        }
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        screenState = .initial
    }
}
