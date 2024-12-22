import Foundation
import Combine

class ChatViewModel: ObservableObject {
    private let getMessagesUseCase: GetMessagesUseCase
    private var cancellables: Set<AnyCancellable> = []
    private let conversation: ConversationUI
    
    @Published var messages: [Message] = []
    @Published var messageToSend: String = ""
    
    init(
        getMessagesUseCase: GetMessagesUseCase,
        conversation: ConversationUI
    ) {
        self.getMessagesUseCase = getMessagesUseCase
        self.conversation = conversation
        fetchMessages()
    }
    
    private func fetchMessages() {
        getMessagesUseCase.execute(conversationId: conversation.id)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error: \(error)")
                }
            } receiveValue: { [weak self] messages in
                self?.messages = messages.sorted(by: { $0.date > $1.date })
            }
            .store(in: &cancellables)
    }
}
