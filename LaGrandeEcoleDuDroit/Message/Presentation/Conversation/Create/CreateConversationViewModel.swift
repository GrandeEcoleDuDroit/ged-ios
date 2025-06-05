import SwiftUI
import Combine

class CreateConversationViewModel: ObservableObject {
    private var defaultUsers: [User] = []
    private var cancellables = Set<AnyCancellable>()
    
    private let userRepository: UserRepository
    private let getLocalConversationUseCase: GetLocalConversationUseCase
    
    @Published var uiState: CreateConversationUiState = CreateConversationUiState()
    @Published var event: SingleUiEvent? = nil
    
    init(
        userRepository: UserRepository,
        getLocalConversationUseCase: GetLocalConversationUseCase
    ) {
        self.userRepository = userRepository
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
            return
        }
        
        uiState.loading = true
        
        Task {
            let users = await userRepository.getUsers().filter { $0.id != user.id }
            updateUiState(uiState.with({
                $0.loading = false
                $0.users = users
            }))
            DispatchQueue.main.sync { [weak self] in
                self?.defaultUsers = users
            }
        }
    }
    
    private func updateUiState(_ uiState: CreateConversationUiState) {
        DispatchQueue.main.sync { [weak self] in
            self?.uiState = uiState
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
