import SwiftUI
import Combine

class CreateConversationViewModel: ViewModel {
    private let userRepository: UserRepository
    private let blockedUserRepository: BlockedUserRepository
    private let getUsersUseCase: GetUsersUseCase
    
    @Published private(set) var uiState = CreateConversationUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private var defaultUsers: [User] = []
    private var cancellables = Set<AnyCancellable>()
    
    init(
        userRepository: UserRepository,
        blockedUserRepository: BlockedUserRepository,
        getUsersUseCase: GetUsersUseCase
    ) {
        self.userRepository = userRepository
        self.blockedUserRepository = blockedUserRepository
        self.getUsersUseCase = getUsersUseCase
        
        fetchUsers()
    }
    
    func onUserQueryChange(_ query: String) {
        if query.isBlank() {
            uiState.users = defaultUsers
        } else {
            uiState.users = defaultUsers.filter {
                $0.fullName
                    .lowercased()
                    .contains(query.lowercased())
            }
        }
    }
    
    private func fetchUsers() {
        guard let user = userRepository.currentUser else {
            event = ErrorEvent(message: stringResource(.currentUserNotFoundError))
            return
        }
        
        let blockedUserIds = blockedUserRepository.currentBlockedUserIds
        Task { @MainActor [weak self] in
            let users = await self?.getUsersUseCase.execute()
                .filter { $0.id != user.id && !blockedUserIds.contains($0.id) }
                .sorted { $0.fullName < $1.fullName }
            ?? []
            
            self?.uiState.users = users
            self?.defaultUsers = users
        }
    }
    
    struct CreateConversationUiState: Withable {
        fileprivate(set) var users: [User]? = nil
    }
}
