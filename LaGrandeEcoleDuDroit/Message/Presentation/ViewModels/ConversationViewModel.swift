import Foundation
import Combine

class ConversationViewModel: ObservableObject {
    private let tag = String(describing: ConversationViewModel.self)
    private let getConversationsUIUseCase: GetConversationsUIUseCase
    private let deleteConversationUseCase: DeleteConversationUseCase
    private var cancellables: Set<AnyCancellable> = []
    private var defaultConversations: [String: ConversationUI] = [:]
    
    @Published var conversationsMap: [String: ConversationUI] = [:]
    @Published var conversationState: ConversationState = .idle
    @Published var searchConversations: String = ""
    
    init(
        getConversationsUIUseCase: GetConversationsUIUseCase,
        deleteConversationUseCase: DeleteConversationUseCase
    ) {
        self.getConversationsUIUseCase = getConversationsUIUseCase
        self.deleteConversationUseCase = deleteConversationUseCase
        listenConversations()
        listenSearchChanges()
    }
    
    func deleteConversation(conversationId: String) {
        Task {
            do {
                try await deleteConversationUseCase.execute(conversationId: conversationId)
                DispatchQueue.main.async { [weak self] in
                    self?.conversationsMap.removeValue(forKey: conversationId)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.conversationState = .error(message: getString(.errorDeletingConversation))
                }
            }
        }
    }
    
    private func listenConversations() {
        getConversationsUIUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                    case .finished: break
                    case .failure(let conversationError):
                        switch conversationError {
                            case.notFound:
                                e(self?.tag ?? "ConversationViewModel", getString(.errorGettingConversations))
                                self?.conversationState = .error(message: getString(.errorGettingConversations))
                            case .createFailed:
                                e(self?.tag ?? "ConversationViewModel", getString(.errorCreatingConversation))
                                self?.conversationState = .error(message: getString(.errorCreatingConversation))
                            default: break
                        }
                    }
            } receiveValue: { [weak self] conversationUI in
                self?.conversationsMap[conversationUI.id] = conversationUI
                self?.defaultConversations = self?.conversationsMap ?? [:]
                self?.conversationState = .idle
            }
            .store(in: &cancellables)
    }
    
    private func listenSearchChanges() {
        $searchConversations
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] searchedConversations in
                self?.filterConversations(filter: searchedConversations)
            }
            .store(in: &cancellables)
    }
    
    private func filterConversations(filter: String) {
        guard !filter.isEmpty else {
            conversationsMap = defaultConversations
            return
        }
        
        conversationsMap = defaultConversations.filter {
            $0.value.interlocutor.fullName
                .lowercased()
                .contains(filter.lowercased())
        }
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        getConversationsUIUseCase.stop()
    }
}
