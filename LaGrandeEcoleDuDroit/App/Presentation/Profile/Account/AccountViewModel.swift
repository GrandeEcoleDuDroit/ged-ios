import Foundation
import SwiftUI
import Combine

class AccountViewModel: ObservableObject {
    private let updateProfilePictureUseCase: UpdateProfilePictureUseCase
    private let deleteProfilePictureUseCase: DeleteProfilePictureUseCase
    private let networkMonitor: NetworkMonitor
    private let userRepository: UserRepository
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var uiState: AccountUiState = AccountUiState()
    @Published var event: SingleUiEvent? = nil
    private var tasks = Set<Task<Void, Never>>()
    
    init(
        updateProfilePictureUseCase: UpdateProfilePictureUseCase,
        deleteProfilePictureUseCase: DeleteProfilePictureUseCase,
        networkMonitor: NetworkMonitor,
        userRepository: UserRepository
    ) {
        self.updateProfilePictureUseCase = updateProfilePictureUseCase
        self.deleteProfilePictureUseCase = deleteProfilePictureUseCase
        self.networkMonitor = networkMonitor
        self.userRepository = userRepository
        initCurrentUser()
    }
    
    func updateProfilePicture(imageData: Data?) {
        guard let imageData = imageData else {
            return event = ErrorEvent(message: "Image data is required.")
        }
        
        uiState.loading = true
        
        let task = Task {  [weak self] in
            do {
                try await self?.updateProfilePictureUseCase.execute(imageData: imageData)
                DispatchQueue.main.sync { [weak self] in
                    self?.resetValues()
                }
            } catch {
                DispatchQueue.main.sync { [weak self] in
                    self?.resetValues()
                    self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
                }
            }
        }
        tasks.insert(task)
    }
    
    func deleteProfilePicture() {
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: getString(.noInternetConectionError))
        }
        
        guard let user = uiState.user else {
            return event = ErrorEvent(message: getString(.userNotFoundError))
        }
        
        uiState.loading = true
        
        let task = Task { [weak self] in
            do {
                if let url = user.profilePictureUrl {
                    try await self?.deleteProfilePictureUseCase.execute(userId: user.id, profilePictureUrl: url)
                }
                DispatchQueue.main.sync { [weak self] in
                    self?.resetValues()
                }
            } catch {
                DispatchQueue.main.sync { [weak self] in
                    self?.resetValues()
                    self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
                }
            }
        }
        tasks.insert(task)
    }
    
    func onScreenStateChange(_ state: AccountScreenState) {
        uiState.screenState = state
    }
    
    private func initCurrentUser() {
        userRepository.user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.uiState.user = user
            }.store(in: &cancellables)
    }
    
    private func resetValues() {
        uiState.screenState = .read
        uiState.loading = false
    }
    
    struct AccountUiState: Withable {
        var user: User? = nil
        var loading: Bool = false
        var screenState: AccountScreenState = .read
    }
    
    deinit {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
        print("AccountViewModel deinitialized")
    }
}

enum AccountScreenState {
   case edit, read
}
