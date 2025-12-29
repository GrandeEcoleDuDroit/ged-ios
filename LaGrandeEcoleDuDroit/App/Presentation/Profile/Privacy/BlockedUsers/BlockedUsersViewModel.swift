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
        networkMonitor: NetworkMonitor,
        getBlockedUsersUseCase: GetBlockedUsersUseCase
    ) {
        self.blockedUserRepository = blockedUserRepository
        self.userRepository = userRepository
        self.networkMonitor = networkMonitor
        
        Task { @MainActor in
            uiState.blockedUsers = await getBlockedUsersUseCase.execute().sorted { $0.fullName < $1.fullName }
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
                try await self?.blockedUserRepository.unblockUser(currentUserId: currentUserId, blockedUserId: userId)
                self?.uiState.blockedUsers?.removeAll { $0.id == userId }
                self?.uiState.loading = false
            } catch {
                self?.uiState.loading = false
                self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
            }
        }
    }
    
    struct BlockedUsersUiState {
        fileprivate(set) var blockedUsers: [User]?
        fileprivate(set) var loading: Bool = false
    }
}
