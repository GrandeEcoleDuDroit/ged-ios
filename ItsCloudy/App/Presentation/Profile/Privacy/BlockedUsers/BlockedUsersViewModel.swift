import Foundation

class BlockedUsersViewModel: ViewModel {
    private let blockedUserRepository: BlockedUserRepository
    private let userRepository: UserRepository
    private let getBlockedUsersUseCase: GetBlockedUsersUseCase
    
    @Published private(set) var uiState: BlockedUsersUiState = BlockedUsersUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    
    init(
        blockedUserRepository: BlockedUserRepository,
        userRepository: UserRepository,
        getBlockedUsersUseCase: GetBlockedUsersUseCase
    ) {
        self.blockedUserRepository = blockedUserRepository
        self.userRepository = userRepository
        self.getBlockedUsersUseCase = getBlockedUsersUseCase
        initUiState()
    }
    
    func unblockUser(userId: String) {
        guard let currentUserId = userRepository.currentUser?.id else {
            return
        }
        
        performRequest { [weak self] in
            try await self?.blockedUserRepository.removeBlockedUser(currentUserId: currentUserId, blockedUserId: userId)
            self?.uiState.blockedUsers?.removeAll { $0.id == userId }
        }
    }
    
    private func performRequest(block: @escaping () async throws -> Void) {
        performUiBlockingRequest(
            block: block,
            onLoading: { [weak self] in
                self?.uiState.loading = true
            },
            onError: { [weak self] in
                self?.event = ErrorEvent(message: $0.localizedDescription)
            },
            onFinshed: { [weak self] in
                self?.uiState.loading = false
            }
        )
    }
    
    private func initUiState() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.uiState.blockedUsers = await self.getBlockedUsersUseCase.execute().sorted { $0.fullName < $1.fullName }
        }
    }
    
    struct BlockedUsersUiState {
        fileprivate(set) var blockedUsers: [User]?
        fileprivate(set) var loading: Bool = false
    }
}
