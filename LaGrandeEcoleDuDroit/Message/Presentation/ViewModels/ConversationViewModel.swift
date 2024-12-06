import Foundation
import Combine

class ConversationViewModel: ObservableObject {
    private let getConversationsUseCase: GetConversationsUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var conversations: [Conversation] = []
    @Published var conversationState: ConversationState = .idle
    
    init(getConversationsUseCase: GetConversationsUseCase) {
        self.getConversationsUseCase = getConversationsUseCase
        fetchConversations()
    }
    
    private func fetchConversations() {
        updateConversationState(state: .loading)
        
        getConversationsUseCase.execute()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.updateConversationState(state: .idle)
                    break
                case .failure(let error):
                    self.updateConversationState(state: .idle)
                    print("Error fetching conversations: \(error)")
                    
                }
            }, receiveValue: { [weak self] conversations in
                self?.conversations = conversations.sorted(by: { $0.message.date > $1.message.date })
            })
            .store(in: &cancellables)
    }
    
    private func updateConversationState(state: ConversationState) {
        DispatchQueue.main.async {
            self.conversationState = state
        }
    }
}
