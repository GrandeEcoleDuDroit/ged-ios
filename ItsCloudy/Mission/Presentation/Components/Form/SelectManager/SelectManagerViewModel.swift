import Combine

class SelectManagerViewModel: ViewModel {
    @Published var uiState = SelectManagerUiState()
    private let defaultUsers: [User]
    private let previousSelectedManagers: Set<User>
    
    init(
        users: [User],
        previousSelectedManagers: Set<User>
    ) {
        self.defaultUsers = users
        self.previousSelectedManagers = previousSelectedManagers
        self.uiState.users = users
        self.uiState.selectedManagers = previousSelectedManagers
    }
    
    func onManagerClick(_ user: User) {
        if uiState.selectedManagers.contains(user) {
            uiState.selectedManagers.remove(user)
        } else {
            uiState.selectedManagers.insert(user)
        }
        
        uiState.saveEnabled =
            !uiState.selectedManagers.isEmpty &&
                uiState.selectedManagers != previousSelectedManagers
    }
    
    func onUserQueryChange(_ query: String) {
        filterUsersByName(query)
    }
    
    private func filterUsersByName(_ query: String) {
        let users = if query.isBlank() {
            defaultUsers
        } else {
            defaultUsers.filter {
                $0.fullName
                    .lowercased()
                    .contains(query.lowercased())
            }
        }
        
        uiState.users = users
    }
    
    struct SelectManagerUiState {
        fileprivate(set) var users: [User] = []
        fileprivate(set) var selectedManagers: Set<User> = []
        var userQuery: String = ""
        fileprivate(set) var saveEnabled: Bool = false
    }
}
