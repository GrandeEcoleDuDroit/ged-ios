import Foundation

class BlockedUsersViewModel: ViewModel {
    private let blockedUserRepository: BlockedUserRepository
    private let userRepository: UserRepository
    private let networkMonitor: NetworkMonitor
    
    @Published private(set) var uiState: BlockedUsersUiState = BlockedUsersUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    
    init(
        blockedUserRepository: BlockedUserRepository,
        userRepository: UserRepository,
        networkMonitor: NetworkMonitor
    ) {
        self.blockedUserRepository = blockedUserRepository
        self.userRepository = userRepository
        self.networkMonitor = networkMonitor
        
        initBlockedUsers()
    }
    
    func unblockUser(userId: String) {
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: getString(.noInternetConectionError))
        }
        guard let currentUserId = userRepository.currentUser?.id else {
            return
        }
        
        uiState.loading = true
        
        Task { @MainActor [weak self] in
            do {
                try await self?.blockedUserRepository.unblockUser(currentUserId: currentUserId, userId: userId)
                self?.uiState.blockedUsers.removeAll { $0.id == userId }
                self?.uiState.loading = false
            } catch {
                self?.uiState.loading = false
                self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
            }
        }
    }

    private func initBlockedUsers() {
        let blockedUserIds = blockedUserRepository.currentBlockedUserIds
        for userId in blockedUserIds {
            Task { @MainActor [weak self] in
                if let user = try? await self?.userRepository.getUser(userId: userId) {
                    guard let blockedUsers = self?.uiState.blockedUsers else {
                        return
                    }
                    self?.uiState.blockedUsers = (blockedUsers + [user]).sorted { $0.fullName < $1.fullName }
                }
            }
        }
    }
    
    struct BlockedUsersUiState {
        var blockedUsers: [User] = []
        var loading: Bool = false
    }
}
