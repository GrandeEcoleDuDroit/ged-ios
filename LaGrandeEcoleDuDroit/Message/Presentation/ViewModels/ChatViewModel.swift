import Foundation
import Combine

private let tag = String(describing: ChatViewModel.self)

class ChatViewModel: ObservableObject {
    private let getMessagesUseCase: GetMessagesUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let generateIdUseCase: GenerateIdUseCase
    private let createConversationUseCase: CreateConversationUseCase
    private let sendMessageUseCase: SendMessageUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var conversation: ConversationUI
    @Published var messages: [String:Message] = [:]
    @Published var textToSend: String = ""
    
    init(
        getMessagesUseCase: GetMessagesUseCase,
        getCurrentUserUseCase: GetCurrentUserUseCase,
        generateIdUseCase: GenerateIdUseCase,
        createConversationUseCase: CreateConversationUseCase,
        sendMessageUseCase: SendMessageUseCase,
        conversation: ConversationUI
    ) {
        self.getMessagesUseCase = getMessagesUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.generateIdUseCase = generateIdUseCase
        self.createConversationUseCase = createConversationUseCase
        self.sendMessageUseCase = sendMessageUseCase
        self.conversation = conversation
        
        fetchMessages()
    }
    
    private func fetchMessages() {
        if case .created = conversation.state {
            getMessagesUseCase.execute(conversationId: conversation.id)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            e(tag, "Error: \(error)")
                    }
                } receiveValue: { [weak self] message in
                    self?.messages[message.id] = message
                }
                .store(in: &cancellables)
        }
    }
    
    func sendMessage() {
        guard !textToSend.isEmpty, let currentUser = getCurrentUserUseCase.execute().value else {
            return
        }
        
        let message = Message(
            id: generateIdUseCase.execute(),
            conversationId: conversation.id,
            content: textToSend,
            senderId: currentUser.id,
            type: .text,
            state: .loading
        )
        
        if case .notCreated = conversation.state {
            conversation.state = .creating
            
            Task {
                do {
                    try await createConversationUseCase.execute(conversationUI: conversation)
                    updateConversationState(.created)
                    
                    try await sendMessageUseCase.execute(message: message)
                    fetchMessages()
                } catch {
                    e(tag, "Error sending message: \(error)")
                    updateConversationState(.error(message: "Failed to sending message"))
                }
            }
        } else {
            Task {
                do {
                    try await sendMessageUseCase.execute(message: message)
                } catch {
                    e(tag, "Error sending message: \(error)")
                }
            }
        }
        
        textToSend = ""
    }
    
    private func updateConversationState(_ state: ConversationState) {
        if Thread.isMainThread {
            conversation.state = state
        } else {
            DispatchQueue.main.sync { [weak self] in
                self?.conversation.state = state
            }
        }
    }
}
