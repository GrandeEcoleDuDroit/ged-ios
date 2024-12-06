import SwiftUI

class CreateConversationViewModel: ObservableObject {
    private let getUsersUseCase: GetUsersUseCase
    
    @Published var conversationState: ConversationState = .idle
    @Published var users: [User] = []
    
    init(
        getUsersUseCase: GetUsersUseCase
    ) {
        self.getUsersUseCase = getUsersUseCase
        fetchAllUsers()
    }
    
    func fetchAllUsers() {
        conversationState = .loading
        Task {
            do {
                users = try await getUsersUseCase.execute()
                updateConversationState(state: .idle)
            }
            catch {
                updateConversationState(state: .error(message: error.localizedDescription))
            }
        }
        
    }
    
    private func updateConversationState(state: ConversationState) {
        DispatchQueue.main.async {
            self.conversationState = state
        }
    }
}
