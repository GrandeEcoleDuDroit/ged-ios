import Foundation
import Combine

class ConversationViewModel: ViewModel {
    private let userRepository: UserRepository
    private let deleteConversationUseCase: DeleteConversationUseCase
    private let getConversationsUiUseCase: GetConversationsUiUseCase
    
    @Published private(set) var uiState: ConversationUiState = ConversationUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private var cancellables: Set<AnyCancellable> = []
    private var defaultConversations: [ConversationUi] = []
    
    init(
        userRepository: UserRepository,
        getConversationsUiUseCase: GetConversationsUiUseCase,
        deleteConversationUseCase: DeleteConversationUseCase
    ) {
        self.userRepository = userRepository
        self.getConversationsUiUseCase = getConversationsUiUseCase
        self.deleteConversationUseCase = deleteConversationUseCase
        listenConversations()
    }
    
    func deleteConversation(conversation: Conversation) {
        Task { [weak self] in
            do {
                guard let user = self?.userRepository.currentUser else {
                    throw UserError.currentUserNotFound
                }
                try await self?.deleteConversationUseCase.execute(conversation: conversation, userId: user.id)
            } catch {
                guard let self else { return }
                self.event = ErrorEvent(message: self.mapErrorMessage(error))
            }
        }
    }
    
    private func listenConversations() {
        getConversationsUiUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] conversations in
                let sortedConversations = conversations.sorted {
                    $0.lastMessage.date > $1.lastMessage.date
                }
                self?.uiState.conversations = sortedConversations
                self?.defaultConversations = sortedConversations
            }.store(in: &cancellables)
    }
    
    private func mapErrorMessage(_ error: Error) -> String {
        mapNetworkErrorMessage(error) {
            if error as? UserError == .currentUserNotFound {
                getString(.userNotFound)
            } else {
                getString(.unknownError)
            }
        }
    }
    
    struct ConversationUiState {
        var conversations: [ConversationUi] = []
        var loading = true
    }
}
