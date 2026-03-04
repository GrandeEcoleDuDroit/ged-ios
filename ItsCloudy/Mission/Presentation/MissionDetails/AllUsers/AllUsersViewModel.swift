import Combine

class AllUsersViewModel: ViewModel {
    @Published private(set) var uiState = AllUsersUiState()
    private var defaultUsers: [User] = []
    
    init(users: [User]) {
        defaultUsers = users
        uiState.users = users
    }
    
    func onUserQueryChange(_ query: String) {
        filterUserByName(query)
    }
    
    private func filterUserByName(_ query: String) {
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
    
    struct AllUsersUiState {
        fileprivate(set) var users: [User] = []
    }
}
