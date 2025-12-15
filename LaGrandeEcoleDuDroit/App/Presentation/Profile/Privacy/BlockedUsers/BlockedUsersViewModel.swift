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
        
        Task { @MainActor in
            await initBlockedUsers()
        }
    }
    
    func unblockUser(userId: String) {
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: stringResource(.noInternetConectionError))
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

    private func initBlockedUsers() async {
        let blockedUserIds = blockedUserRepository.currentBlockedUserIds
        
        let blockedUsers = await withTaskGroup(of: User?.self) { [weak self] group in
            var result: [User] = []
            
            for userId in blockedUserIds {
                group.addTask {
                    try? await self?.userRepository.getUser(userId: userId)
                }
            }
            
            for await user in group {
                if let user {
                    result.append(user)
                }
            }
            
            return result.sorted { $0.fullName < $1.fullName }
        }
        
        uiState.blockedUsers = blockedUsers
    }
    
    struct BlockedUsersUiState {
        var blockedUsers: [User] = []
        var loading: Bool = false
    }
}
