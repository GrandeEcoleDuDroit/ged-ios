import Combine
import Foundation

class UserViewModel: ViewModel {
    private let userId: String
    private let userRepository: UserRepository
    private let blockedUserRepository: BlockedUserRepository
    private let networkMonitor: NetworkMonitor
    
    @Published private(set) var uiState: UserUiState = UserUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private var cancellables: Set<AnyCancellable> = []
    
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
        
        Task { @MainActor [weak self] in
            do {
                try await self?.userRepository.reportUser(report: report)
                self?.uiState.loading = false
            } catch {
                self?.uiState.loading = false
                self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
            }
        }
    }
    
    func blockUser(userId: String) {
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: getString(.noInternetConectionError))
        }
        guard let currentUserId = userRepository.currentUser?.id else {
            return
        }
        
        uiState.loading = true
        
        Task { @MainActor [weak self] in
            do {
                try await self?.blockedUserRepository.blockUser(currentUserId: currentUserId, userId: userId)
                self?.uiState.loading = false
            } catch {
                self?.uiState.loading = false
                self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
            }
        }
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
                self?.uiState.loading = false
            } catch {
                self?.uiState.loading = false
                self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
            }
        }
    }

    
    private func listenCurrentUser() {
        userRepository.user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.uiState.currentUser = user
            }
            .store(in: &cancellables)
    }
    
    private func listenBlockedUserIds(userId: String) {
        blockedUserRepository.blockedUserIds
            .receive(on: DispatchQueue.main)
            .sink { [weak self] blockedUserIds in
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
