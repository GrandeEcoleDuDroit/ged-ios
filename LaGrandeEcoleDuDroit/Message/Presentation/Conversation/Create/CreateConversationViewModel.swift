import SwiftUI
import Combine

class CreateConversationViewModel: ViewModel {
    private let userRepository: UserRepository
    private let blockedUserRepository: BlockedUserRepository
    private let getLocalConversationUseCase: GetConversationUseCase
    
    @Published var uiState: CreateConversationUiState = CreateConversationUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private var defaultUsers: [User] = []
    private var cancellables = Set<AnyCancellable>()
    
    init(
        userRepository: UserRepository,
        blockedUserRepository: BlockedUserRepository,
        getLocalConversationUseCase: GetConversationUseCase
    ) {
        self.userRepository = userRepository
        self.blockedUserRepository = blockedUserRepository
        self.getLocalConversationUseCase = getLocalConversationUseCase
        fetchUsers()
    }
    
    func onQueryChange(_ query: String) {
        uiState.query = query
        if query.isBlank {
            uiState.users = defaultUsers
        } else {
            uiState.users = defaultUsers.filter {
                $0.fullName
                    .lowercased()
                    .contains(query.lowercased())
            }
        }
    }
    
    func getConversation(interlocutor: User) async -> Conversation? {
        do {
            return try await getLocalConversationUseCase.execute(interlocutor: interlocutor)
        } catch {
            event = ErrorEvent(message: mapNetworkErrorMessage(error))
            return nil
        }
    }
    
    private func fetchUsers() {
        guard let user = userRepository.currentUser else {
            event = ErrorEvent(message: getString(.userNotFound))
            return
        }
        uiState.loading = true
        
        let blockedUserIds = blockedUserRepository.getLocalBlockedUserIds()
        Task { @MainActor [weak self] in
            let users = await self?.userRepository.getUsers()
                .filter { $0.id != user.id && !blockedUserIds.contains($0.id) }
                .sorted { $0.fullName < $1.fullName }
            ?? []
            
            self?.uiState.loading = false
            self?.uiState.users = users
            self?.defaultUsers = users
        }
    }
    
    struct CreateConversationUiState: Withable {
        fileprivate(set) var users: [User] = []
        fileprivate(set) var loading: Bool = false
        var query: String = ""
    }
}
