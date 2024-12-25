import Foundation
import Combine

class ConversationViewModel: ObservableObject {
    private let tag = String(describing: ConversationViewModel.self)
    private let getConversationsUIUseCase: GetConversationsUIUseCase
    private var cancellables: Set<AnyCancellable> = []
    private var defaultConversations: [String: ConversationUI] = [:]
    
    @Published var conversationsMap: [String: ConversationUI] = [:]
    @Published var conversationState: ConversationState = .idle
    @Published var searchConversations: String = ""
    
    init(getConversationsUIUseCase: GetConversationsUIUseCase) {
        self.getConversationsUIUseCase = getConversationsUIUseCase
        listenConversations()
        listenSearchChanges()
    }
    
    private func listenConversations() {
        getConversationsUIUseCase.execute()
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let conversationError):
                    switch conversationError {
                    case.notFound:
                        e(self?.tag ?? "ConversationViewModel", getString(.errorGettingConversations))
                        self?.updateConversationState(state: .error(message: getString(.errorGettingConversations)))
                    case .insertFailed:
                        e(self?.tag ?? "ConversationViewModel", getString(.errorCreatingConversation))
                        self?.updateConversationState(state: .error(message: getString(.errorCreatingConversation)))
                    }
                }
            } receiveValue: { [weak self] conversationUI in
                guard let self else { return }
                
                self.conversationsMap[conversationUI.id] = conversationUI
                self.defaultConversations = self.conversationsMap
                self.updateConversationState(state: .idle)
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
    
    private func updateConversationState(state: ConversationState) {
        DispatchQueue.main.async { [weak self] in
            self?.conversationState = state
        }
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        getConversationsUIUseCase.stop()
    }
}
