import SwiftUI
import Combine

class CreateConversationViewModel: ObservableObject {
    private var defaultUsers: [User] = []
    private var cancellables = Set<AnyCancellable>()
    private let tag = String(describing: CreateConversationViewModel.self)
    private let userRepository: UserRepository
    private let blockedUserRepository: BlockedUserRepository
    private let getLocalConversationUseCase: GetConversationUseCase
    
    @Published var uiState: CreateConversationUiState = CreateConversationUiState()
    @Published var event: SingleUiEvent? = nil
    
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
            updateEvent(ErrorEvent(message: mapNetworkErrorMessage(error)))
            return nil
        }
    }
    
    private func fetchUsers() {
        guard let user = userRepository.currentUser else {
            uiState.loading = false
            updateEvent(ErrorEvent(message: getString(.userNotFound)))
            return
        }
        let blockedUserIds = blockedUserRepository.getLocalBlockedUserIds()
        
        uiState.loading = true
        
        Task {
            let users = await userRepository.getUsers()
                .filter { $0.id != user.id && !blockedUserIds.contains($0.id) }
                .sorted { $0.fullName < $1.fullName }
            
            DispatchQueue.main.sync { [weak self] in
                self?.uiState.loading = false
                self?.uiState.users = users
                self?.defaultUsers = users
            }
        }
    }
    
    private func updateEvent(_ event: SingleUiEvent) {
        DispatchQueue.main.sync { [weak self] in
            self?.event = event
        }
    }
    
    struct CreateConversationUiState: Withable {
        var users: [User] = []
        var loading: Bool = true
        var query: String = ""
    }
}
