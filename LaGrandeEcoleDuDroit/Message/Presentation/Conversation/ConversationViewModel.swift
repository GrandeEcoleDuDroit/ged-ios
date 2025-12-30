import Foundation
import Combine

class ConversationViewModel: ViewModel {
    private let userRepository: UserRepository
    private let deleteConversationUseCase: DeleteConversationUseCase
    private let getConversationsUiUseCase: GetConversationsUiUseCase
    private let getLocalConversationUseCase: GetLocalConversationUseCase
    private let recreateConversationUseCase: RecreateConversationUseCase

    @Published private(set) var uiState: ConversationUiState = ConversationUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private var cancellables: Set<AnyCancellable> = []
    private var defaultConversations: [ConversationUi] = []
    
    init(
        userRepository: UserRepository,
        getConversationsUiUseCase: GetConversationsUiUseCase,
        deleteConversationUseCase: DeleteConversationUseCase,
        getLocalConversationUseCase: GetLocalConversationUseCase,
        recreateConversationUseCase: RecreateConversationUseCase
    ) {
        self.userRepository = userRepository
        self.getConversationsUiUseCase = getConversationsUiUseCase
        self.deleteConversationUseCase = deleteConversationUseCase
        self.getLocalConversationUseCase = getLocalConversationUseCase
        self.recreateConversationUseCase = recreateConversationUseCase
        
        listenConversations()
    }
    
    func deleteConversation(conversation: Conversation) {
        Task { @MainActor [weak self] in
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
    
    func getConversation(interlocutor: User) async -> Conversation? {
        do {
            return try await getLocalConversationUseCase.execute(interlocutor: interlocutor)
        } catch {
            event = ErrorEvent(message: mapNetworkErrorMessage(error))
            return nil
        }
    }
    
    func recreateConversation(conversation: Conversation) {
        guard let currentUserId = userRepository.currentUser?.id else { return }
        Task {
            await recreateConversationUseCase.execute(conversation: conversation, userId: currentUserId)
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
                stringResource(.currentUserNotFoundError)
            } else {
                stringResource(.unknownError)
            }
        }
    }
    
    struct ConversationUiState {
        var conversations: [ConversationUi] = []
        var loading = true
    }
}
