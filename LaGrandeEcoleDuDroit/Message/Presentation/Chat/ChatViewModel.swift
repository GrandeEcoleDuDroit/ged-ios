import Foundation
import Combine

private let tag = String(describing: ChatViewModel.self)

class ChatViewModel: ObservableObject {
    private var conversation: Conversation
    private let userRepository: UserRepository
    private let messageRepository: MessageRepository
    private let sendMessageUseCase: SendMessageUseCase
    private var cancellables: Set<AnyCancellable> = []
    private let user: User?
    
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
        
        fetchMessages()
    }
    
    func sendMessage() {
        guard !uiState.text.isEmpty, let user = user else {
            return
        }
        
        sendMessageUseCase.execute(conversation: conversation, user: user, content: uiState.text)
        uiState.text = ""
    }
    
    private func fetchMessages() {
        messageRepository.getMessages(conversationId: conversation.id)
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] message in
                self?.uiState.messages[message.id] = message
            }.store(in: &cancellables)
    }
    
    struct ChatUiState {
        var messages: [Int: Message] = [:]
        var text: String = ""
    }
}
