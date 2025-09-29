import Combine
import Foundation

class UserViewModel: ObservableObject {
    private let userId: String
    private let userRepository: UserRepository
    private let blockedUserRepository: BlockedUserRepository
    private let networkMonitor: NetworkMonitor
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var uiState: UserUiState = UserUiState()
    @Published var event: SingleUiEvent? = nil
    
    init(
        userId: String,
        userRepository: UserRepository,
        blockedUserRepository: BlockedUserRepository,
        networkMonitor: NetworkMonitor
    ) {
        self.userId = userId
        self.userRepository = userRepository
        self.blockedUserRepository = blockedUserRepository
        self.networkMonitor = networkMonitor
        
        listenCurrentUser()
        listenBlockedUserIds(userId: userId)
    }
    
    func reportUser(report: UserReport) {
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: getString(.noInternetConectionError))
        }
        
        uiState.loading = true

        Task {
            do {
                try await userRepository.reportUser(report: report)
                DispatchQueue.main.sync { [weak self] in
                    self?.uiState.loading = false
                }
            } catch {
                DispatchQueue.main.sync { [weak self] in
                    self?.uiState.loading = false
                    self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
                }
            }
        }
    }
    
    func blockUser(userId: String) {
        uiState.loading = true
        guard let currentUserId = userRepository.currentUser?.id else { return }
        
        Task {
            do {
                try await blockedUserRepository.blockUser(currentUserId: currentUserId, userId: userId)
                DispatchQueue.main.sync { [weak self] in
                    self?.uiState.loading = false
                }
            } catch {
                DispatchQueue.main.sync { [weak self] in
                    self?.uiState.loading = false
                    self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
                }
            }
        }
    }
    
    func unblockUser(userId: String) {
        uiState.loading = true
        guard let currentUserId = userRepository.currentUser?.id else { return }
        
        Task {
            do {
                try await blockedUserRepository.unblockUser(currentUserId: currentUserId, userId: userId)
                DispatchQueue.main.sync { [weak self] in
                    self?.uiState.loading = false
                }
            } catch {
                DispatchQueue.main.sync { [weak self] in
                    self?.uiState.loading = false
                    self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
                }
            }
        }
    }

    
    private func listenCurrentUser() {
        userRepository.user.sink { [weak self] user in
            self?.uiState.currentUser = user
        }
        .store(in: &cancellables)
    }
    
    private func listenBlockedUserIds(userId: String) {
        blockedUserRepository.blockedUserIds.sink { [weak self] blockedUserIds in
            self?.uiState.userBlocked = blockedUserIds.contains(userId)
        }
        .store(in: &cancellables)
    }
    
    struct UserUiState {
        var currentUser: User? = nil
        var loading: Bool = false
        var userBlocked: Bool = false
    }
}
