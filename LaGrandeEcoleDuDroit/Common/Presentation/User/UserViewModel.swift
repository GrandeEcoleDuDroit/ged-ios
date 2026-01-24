import Combine
import Foundation

class UserViewModel: ViewModel {
    private let userId: String
    private let userRepository: UserRepository
    private let blockedUserRepository: BlockedUserRepository
    
    @Published private(set) var uiState: UserUiState = UserUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        userId: String,
        userRepository: UserRepository,
        blockedUserRepository: BlockedUserRepository
    ) {
        self.userId = userId
        self.userRepository = userRepository
        self.blockedUserRepository = blockedUserRepository
        
        listenCurrentUser()
        listenBlockedUsers(userId: userId)
    }
    
    func reportUser(report: UserReport) {
        performRequest { [weak self] in
            try await self?.userRepository.reportUser(report: report)
        }
    }
    
    func blockUser(userId: String) {
        guard let currentUserId = userRepository.currentUser?.id else {
            return
        }
        
        performRequest { [weak self] in
            try await self?.blockedUserRepository.addBlockedUser(
                currentUserId: currentUserId,
                blockedUser: BlockedUser(userId: userId, date: Date())
            )
        }
    }
    
    func unblockUser(userId: String) {
        guard let currentUserId = userRepository.currentUser?.id else {
            return
        }
        
        performRequest { [weak self] in
            try await self?.blockedUserRepository.removeBlockedUser(
                currentUserId: currentUserId,
                blockedUserId: userId
            )
        }
    }
    
    private func performRequest(block: @escaping () async throws -> Void) {
        performUiBlockingRequest(
            block: block,
            onLoading: { [weak self] in
                self?.uiState.loading = true
            },
            onError: { [weak self] in
                self?.event = ErrorEvent(message: mapNetworkErrorMessage($0))
            },
            onFinshed: { [weak self] in
                self?.uiState.loading = false
            }
        )
    }
    
    private func listenCurrentUser() {
        userRepository.user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.uiState.currentUser = user
            }
            .store(in: &cancellables)
    }
    
    private func listenBlockedUsers(userId: String) {
        blockedUserRepository.blockedUsers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] blockedUsers in
                self?.uiState.isBlocked = blockedUsers.containsKey(userId)
            }
            .store(in: &cancellables)
    }
    
    struct UserUiState {
        var currentUser: User? = nil
        var loading: Bool = false
        var isBlocked: Bool = false
    }
}
