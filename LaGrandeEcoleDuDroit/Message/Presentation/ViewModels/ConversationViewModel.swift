import Foundation
import Combine

class ConversationViewModel: ObservableObject {
    private let tag = String(describing: ConversationViewModel.self)
    private let getConversationsUIUseCase: GetConversationsUIUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var conversationsMap: [String: ConversationUI] = [:]
    @Published var conversationState: ConversationState = .idle
    
    init(getConversationsUIUseCase: GetConversationsUIUseCase) {
        self.getConversationsUIUseCase = getConversationsUIUseCase
        listenConversations()
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
                        e(self?.tag ?? "ConversationViewModel", getString(gedString: GedString.error_getting_conversations))
                        self?.updateConversationState(state: .error(message: getString(gedString: GedString.error_getting_conversations)))
                    }
                }
            } receiveValue: { [weak self] conversationUI in
                self?.conversationsMap[conversationUI.id] = conversationUI
                self?.updateConversationState(state: .idle)
            }
            .store(in: &cancellables)
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
