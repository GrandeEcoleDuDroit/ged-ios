import Foundation
import Combine

class ChatViewModel: ObservableObject {
    private var conversation: Conversation
    private let userRepository: UserRepository
    private let messageRepository: MessageRepository
    private let sendMessageUseCase: SendMessageUseCase
    private var cancellables: Set<AnyCancellable> = []
    private let user: User?
    private var offset: Int = 0
    
    @Published var uiState: ChatUiState = ChatUiState()
    
    init(
        conversation: Conversation,
        userRepository: UserRepository,
        messageRepository: MessageRepository,
        sendMessageUseCase: SendMessageUseCase
    ) {
        self.conversation = conversation
        self.userRepository = userRepository
        self.messageRepository = messageRepository
        self.sendMessageUseCase = sendMessageUseCase
        user = userRepository.currentUser
        getMessages()
        listenMessages()
        seeMessages()
    }
    
    func sendMessage() {
        guard !uiState.text.isEmpty, let user = user else {
            return
        }
        
        let message = Message(
            id: GenerateIdUseCase.intId(),
            senderId: user.id,
            recipientId: conversation.interlocutor.id,
            conversationId: conversation.id,
            content: uiState.text,
            date: Date(),
            seen: false,
            state: .draft
        )
        
        sendMessageUseCase.execute(message: message, conversation: conversation, userId: user.id)
        uiState.text = ""
    }
    
    func loadMessage() {
        getMessages()
        offset += 20
    }
    
    private func getMessages() {
        Task {
            await messageRepository.getMessages(
                conversationId: conversation.id,
                offset: offset
            ).forEach { message in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.uiState.messages[message.id] = message
                }
            }
        }
    }
    
    private func seeMessages() {
        guard let user = user else {
            return
        }
        Task {
            try? await messageRepository.updateSeenMessages(
                conversationId: conversation.id,
                userId: user.id
            )
        }
    }
    
    private func listenMessages() {
        messageRepository.messagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] change in
                change.inserted
                    .filter { $0.conversationId == self?.conversation.id }
                    .forEach { message in
                        self?.addOrUpdateMessage(message)
                        self?.seeMessage(message: message)
                    }
                
                change.updated
                    .filter { $0.conversationId == self?.conversation.id }
                    .forEach { message in
                        self?.addOrUpdateMessage(message)
                        self?.seeMessage(message: message)
                    }
                
                change.deleted
                    .filter { $0.conversationId == self?.conversation.id }
                    .forEach {
                        self?.removeMessage($0)
                    }
            }.store(in: &cancellables)
    }
    
    private func addOrUpdateMessage(_ message: Message) {
        uiState.messages[message.id] = message
    }
    
    private func removeMessage(_ message: Message) {
        uiState.messages[message.id] = nil
    }
    
    private func seeMessage(message: Message) {
        if !message.seen && message.senderId == conversation.interlocutor.id {
            Task { try? await messageRepository.updateSeenMessage(message: message) }
        }
    }
    
    struct ChatUiState {
        var messages: [Int64: Message] = [:]
        var text: String = ""
    }
}
