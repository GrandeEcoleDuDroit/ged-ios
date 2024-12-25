import Foundation
import Combine

class ChatViewModel: ObservableObject {
    private let tag = String(describing: ChatViewModel.self)
    private let getMessagesUseCase: GetMessagesUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let generateIdUseCase: GenerateIdUseCase
    private let createConversationUseCase: CreateConversationUseCase
    private var cancellables: Set<AnyCancellable> = []
    private let conversation: ConversationUI
    
    @Published var messages: [Message] = []
    @Published var textToSend: String = ""
    @Published var conversationState: ConversationState = .notActive
    
    init(
        getMessagesUseCase: GetMessagesUseCase,
        getCurrentUserUseCase: GetCurrentUserUseCase,
        generateIdUseCase: GenerateIdUseCase,
        createConversationUseCase: CreateConversationUseCase,
        conversation: ConversationUI
    ) {
        self.getMessagesUseCase = getMessagesUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.generateIdUseCase = generateIdUseCase
        self.createConversationUseCase = createConversationUseCase
        self.conversation = conversation
    }
    
    func fetchMessages() {
        if conversation.isCreated {
            conversationState = .active
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
                    self?.messages.append(contentsOf: messages.sorted(by: { $0.date < $1.date }))
                }
                .store(in: &cancellables)
        }
    }
    
    func sendMessage() {
        guard !textToSend.isEmpty, let currentUser = getCurrentUserUseCase.execute() else {
            return
        }
        
        let messageToSend = Message(
            id: generateIdUseCase.execute(),
            conversationId: conversation.id,
            content: textToSend,
            senderId: currentUser.id,
            type: "text"
        )
        
        if case .notActive = conversationState {
            conversationState = .creating
            Task {
                do {
                    try await createConversationUseCase.execute(conversationUI: conversation)
                    fetchMessages()
                    updateConversationState(.active)
                } catch {
                    e(tag, "Error creating conversation: \(error)")
                    updateConversationState(.error(message: "Failed to create conversation"))
                }
            }
        }
        
        messages.append(messageToSend)
        textToSend = ""
    }
    
    private func updateConversationState(_ state: ConversationState) {
        DispatchQueue.main.async {
            self.conversationState = state
        }
    }
}
