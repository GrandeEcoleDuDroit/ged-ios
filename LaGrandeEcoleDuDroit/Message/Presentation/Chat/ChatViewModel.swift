import Foundation
import Combine

class ChatViewModel: ObservableObject {
    private var conversation: Conversation
    private let userRepository: UserRepository
    private let messageRepository: MessageRepository
    private let conversationRepository: ConversationRepository
    private let sendMessageUseCase: SendMessageUseCase
    private var cancellables: Set<AnyCancellable> = []
    private let user: User?
    private var offset: Int = 0
    
    @Published var uiState: ChatUiState = ChatUiState()
    @Published var event: SingleUiEvent? = nil
    
    init(
        conversation: Conversation,
        userRepository: UserRepository,
        messageRepository: MessageRepository,
        conversationRepository: ConversationRepository,
        sendMessageUseCase: SendMessageUseCase
    ) {
        self.conversation = conversation
        self.userRepository = userRepository
        self.messageRepository = messageRepository
        self.conversationRepository = conversationRepository
        self.sendMessageUseCase = sendMessageUseCase
        
        user = userRepository.currentUser
        getMessages(offset: offset)
        listenMessages()
        listenConversationChanges()
        seeMessages()
    }
    
    private func listenMessages() {
        messageRepository.messageChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] change in
                change.inserted
                    .filter { $0.conversationId == self?.conversation.id }
                    .forEach { message in
                        self?.addOrUpdateMessage(message)
                        self?.seeMessage(message)
                    }
                
                change.updated
                    .filter { $0.conversationId == self?.conversation.id }
                    .forEach { message in
                        self?.addOrUpdateMessage(message)
                        self?.seeMessage(message)
                    }
                
                change.deleted
                    .filter { $0.conversationId == self?.conversation.id }
                    .forEach { message in
                        self?.uiState.messages[message.id] = nil
                    }
            }.store(in: &cancellables)
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
        
        sendMessageUseCase.execute(conversation: conversation, message: message, userId: user.id)
        uiState.text = ""
    }
    
    func loadMoreMessages() {
        offset += 20
        getMessages(offset: offset)
    }
    
    func resendErrorMessage(_ message: Message) {
        guard let user = user else {
            return
        }
        
        let updatedMessage = message.with(date: Date())
        sendMessageUseCase.execute(conversation: conversation, message: updatedMessage, userId: user.id)
    }
    
    func deleteErrorMessage(_ message: Message) {
        Task {
            do {
                try await messageRepository.deleteLocalMessage(message: message)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.event = ErrorEvent(message: getString(.unknownError))
                }
            }
        }
    }
    
    private func getMessages(offset: Int) {
        Task {
            try? await messageRepository.getMessages(
                conversationId: conversation.id,
                offset: offset
            ).forEach { message in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.uiState.messages[message.id] = message
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
    
    private func seeMessage(_ message: Message) {
        if !message.seen && message.senderId == conversation.interlocutor.id {
            Task { try? await messageRepository.updateSeenMessage(message: message) }
        }
    }
    
    private func addOrUpdateMessage(_ message: Message) {
        uiState.messages[message.id] = message
    }
    
    private func listenConversationChanges() {
        conversationRepository.conversationChanges.map { [weak self] in
            $0.updated.first { $0.id == self?.conversation.id }
        }
        .compactMap { $0 }
        .sink { [weak self] updatedConversation in
            self?.conversation = updatedConversation
        }.store(in: &cancellables)
    }
    
    struct ChatUiState {
        var messages: [Int64: Message] = [:]
        var text: String = ""
        var loading: Bool = false
    }
}
