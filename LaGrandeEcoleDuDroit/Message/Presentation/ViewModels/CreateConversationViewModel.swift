import SwiftUI
import Combine

class CreateConversationViewModel: ObservableObject {
    private var defaultUsers: [User] = []
    private var cancellables = Set<AnyCancellable>()
    private var currentTask: Task<Void, Never>? = nil
    private let getUsersUseCase: GetUsersUseCase
    private let getFilteredUsersUseCase: GetFilteredUsersUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let generateIdUseCase: GenerateIdUseCase
    
    @Published var conversationState: ConversationState = .idle
    @Published var users: [User] = []
    @Published var searchUser: String = ""
    
    init(
        getUsersUseCase: GetUsersUseCase,
        getCurrentUserUseCase: GetCurrentUserUseCase,
        getFilteredUsersUseCase: GetFilteredUsersUseCase,
        generateIdUseCase: GenerateIdUseCase
    ) {
        self.getUsersUseCase = getUsersUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.getFilteredUsersUseCase = getFilteredUsersUseCase
        self.generateIdUseCase = generateIdUseCase
        fetchAllUsers()
        listenSearchChanges()
    }
    
    func generateConversation(interlocutor: User) -> ConversationUI {
        ConversationUI(
            id: generateIdUseCase.execute(),
            interlocutor: interlocutor,
            state: .notCreated
        )
    }
    
    private func fetchAllUsers() {
        guard let currentUser = getCurrentUserUseCase.execute() else {
            return
        }
        
        conversationState = .loading
        Task {
            do {
                let allUsers = try await getUsersUseCase.execute().filter { $0.id != currentUser.id }
                updateUsers(allUsers)
                defaultUsers = allUsers
                updateConversationState(.idle)
            }
            catch {
                updateConversationState(.error(message: error.localizedDescription))
            }
        }
        
    }
    
    private func listenSearchChanges() {
        $searchUser
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] newText in
                self?.fetchFilteredUsers(filter: newText)
            }
            .store(in: &cancellables)
    }
    
    private func fetchFilteredUsers(filter: String) {
        guard !filter.isEmpty, let currentUser = getCurrentUserUseCase.execute() else {
            users = defaultUsers
            return
        }
        
        updateConversationState(.loading)
        currentTask?.cancel()
        currentTask = Task {
            let filteredUsers = await getFilteredUsersUseCase.execute(filter: filter).filter { $0.id != currentUser.id }
            updateUsers(filteredUsers)
            updateConversationState(.idle)
        }
    }
        
    
    private func updateConversationState(_ state: ConversationState) {
        DispatchQueue.main.async {
            self.conversationState = state
        }
    }
    
    private func updateUsers(_ users: [User]) {
        DispatchQueue.main.async {
            self.users = users
        }
    }
}
