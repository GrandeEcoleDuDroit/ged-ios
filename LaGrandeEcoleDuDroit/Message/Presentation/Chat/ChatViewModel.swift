import Foundation
import Combine

class ChatViewModel: ViewModel {
    private let userRepository: UserRepository
    private let messageRepository: MessageRepository
    private let conversationRepository: ConversationRepository
    private let sendMessageUseCase: SendMessageUseCase
    private let notificationMessageManager: MessageNotificationPresenter
    private let blockedUserRepository: BlockedUserRepository
    private let generateIdUseCase: GenerateIdUseCase
    
    @Published var uiState = ChatUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private let newMessagesEventSubject = PassthroughSubject<Message, Never>()
    var newMessagesEventPublisher: AnyPublisher<Message, Never> {
        newMessagesEventSubject.eraseToAnyPublisher()
    }
    private var messagesDict: [String:Message] = [:]
    private var conversation: Conversation
    private let currentUser: User?
    private var cancellables: Set<AnyCancellable> = []
    private var seeMessagesCancellable: AnyCancellable?
    
    init(
        conversation: Conversation,
        userRepository: UserRepository,
        messageRepository: MessageRepository,
        conversationRepository: ConversationRepository,
        sendMessageUseCase: SendMessageUseCase,
        notificationMessageManager: MessageNotificationPresenter,
        blockedUserRepository: BlockedUserRepository,
        generateIdUseCase: GenerateIdUseCase
    ) {
        self.conversation = conversation
        self.userRepository = userRepository
        self.messageRepository = messageRepository
        self.conversationRepository = conversationRepository
        self.sendMessageUseCase = sendMessageUseCase
        self.notificationMessageManager = notificationMessageManager
        self.blockedUserRepository = blockedUserRepository
        self.generateIdUseCase = generateIdUseCase
        
        currentUser = userRepository.currentUser
        getMessages(offset: 0)
        listenMessages()
        listenConversationChanges()
        listenBlockedUserIds()
        notificationMessageManager.clearNotifications(conversationId: conversation.id)
    }
    
    func sendMessage() {
        guard !uiState.messageText.isEmpty, let currentUser else { return }
        
        let message = Message(
            id: generateIdUseCase.execute(),
            senderId: currentUser.id,
            recipientId: conversation.interlocutor.id,
            conversationId: conversation.id,
            content: uiState.messageText,
            date: Date(),
            seen: false,
            state: .draft
        )
        
        Task {
            await sendMessageUseCase.execute(
                conversation: conversation,
                message: message,
                userId: currentUser.id
            )
        }
        
        uiState.messageText = ""
    }
    
    func loadMoreMessages(offset: Int) {
        getMessages(offset: offset)
    }
    
    func resendErrorMessage(_ message: Message) {
        guard let currentUser else { return }
        
        Task {
            await sendMessageUseCase.execute(
                conversation: conversation,
                message: message.copy { $0.date = Date() },
                userId: currentUser.id
            )
        }
    }
    
    func deleteErrorMessage(_ message: Message) {
        Task { @MainActor [weak self] in
            do {
                try await self?.messageRepository.deleteLocalMessage(message: message)
            } catch {
                self?.event = ErrorEvent(message: error.localizedDescription)
            }
        }
    }
    
    func reportMessage(_ report: MessageReport) {
        performRequest { [weak self] in
            try await self?.messageRepository.reportMessage(report: report)
        }
    }
    
    func onMessageTextChange(_ text: String) {
        if text.count <= MessageConstant.characterMax {
            uiState.messageText = text.take(MessageConstant.characterMax)
        }
    }
    
    func unblockUser(userId: String) {
        guard let currentUserId = currentUser?.id else { return }
        performRequest { [weak self] in
            try await self?.blockedUserRepository.removeBlockedUser(
                currentUserId: currentUserId,
                blockedUserId: userId
            )
        }
    }
    
    func deleteChat() {
        guard let currentUserId = currentUser?.id else { return }
        let conversation = conversation
        
        performRequest { [weak self] in
            try await self?.conversationRepository.deleteConversation(
                conversationId: conversation.id,
                userId: currentUserId,
                date: Date()
            )
            try await self?.messageRepository.deleteLocalMessages(conversationId: conversation.id)
            self?.event = ChatEvent.chatDeleted
        }
    }
    
    func startSeeingMessages() {
        seeMessages()
        seeMessagesCancellable = newMessagesEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.seeMessage(message)
            }
    }
    
    func stopSeeingMessages() {
        seeMessagesCancellable?.cancel()
    }
    
    private func performRequest(block: @escaping () async throws -> Void) {
        performUiBlockingRequest(
            block: block,
            onLoading: { [weak self] in
                self?.uiState.loading = true
            },
            onError: { [weak self] in
                self?.event = ErrorEvent(message: mapNetworkErrorMessage($0))
            },
            onFinshed: { [weak self] in
                self?.uiState.loading = false
            }
        )
    }
    
    private func listenMessages() {
        messageRepository.messageChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] change in
                var hasChanged = false
                
                change.inserted.forEach { message in
                    if message.conversationId == self?.conversation.id {
                        self?.messagesDict[message.id] = message
                        hasChanged = true
                        if message.senderId == self?.conversation.interlocutor.id {
                            self?.newMessagesEventSubject.send(message)
                        }
                    }
                }
                
                change.updated.forEach { message in
                    if message.conversationId == self?.conversation.id {
                        self?.messagesDict[message.id] = message
                        hasChanged = true
                    }
                }
                
                change.deleted.forEach { message in
                    if message.conversationId == self?.conversation.id {
                        self?.messagesDict.removeValue(forKey: message.id)
                        hasChanged = true
                    }
                }
                
                if hasChanged {
                    self?.sortMessages()
                }
            }.store(in: &cancellables)
    }
    
    private func getMessages(offset: Int) {
        Task { @MainActor [weak self] in
            guard let conversation = self?.conversation else { return }
            guard let messages = try? await self?.messageRepository.getMessages(
                conversationId: conversation.id,
                offset: offset,
                limit: MessageConstant.loadLimit
            ) else {
                return
            }
            
            if messages.isEmpty {
                self?.uiState.canLoadMoreMessages = false
                return
            }
            
            messages.forEach { self?.messagesDict[$0.id] = $0 }
            self?.sortMessages()
        }
    }
    
    private func seeMessages() {
        guard let currentUser else { return }
        
        Task {
            try? await messageRepository.setMessagesSeen(
                conversationId: conversation.id,
                currentUserId: currentUser.id
            )
        }
    }
    
    func seeMessage(_ message: Message) {
        if !message.seen && message.senderId == conversation.interlocutor.id {
            Task {
                try? await messageRepository.setMessageSeen(message: message)
            }
        }
    }
    
    private func sortMessages() {
        uiState.messages = messagesDict.values.sorted { $0.date > $1.date }
    }
    
    private func listenConversationChanges() {
        conversationRepository.conversationChanges.map { [weak self] change in
            change.updated.first {
                $0.id == self?.conversation.id
            }
        }
        .compactMap { $0 }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] in
            self?.conversation = $0
        }.store(in: &cancellables)
    }
    
    private func listenBlockedUserIds() {
        let interlocutorId = conversation.interlocutor.id
        blockedUserRepository.blockedUsers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] blockedUsers in
                self?.uiState.isBlocked = blockedUsers.has(interlocutorId)
            }.store(in: &cancellables)
    }
    
    struct ChatUiState {
        fileprivate(set) var messages: [Message] = []
        var messageText: String = ""
        fileprivate(set) var loading: Bool = false
        fileprivate(set) var isBlocked: Bool = false
        fileprivate(set) var canLoadMoreMessages: Bool = true
    }
    
    enum ChatEvent: SingleUiEvent {
        case chatDeleted
    }
}
