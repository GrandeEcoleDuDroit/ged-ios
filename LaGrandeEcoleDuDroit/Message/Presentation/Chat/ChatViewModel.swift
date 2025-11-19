import Foundation
import Combine

class ChatViewModel: ViewModel {
    private let userRepository: UserRepository
    private let messageRepository: MessageRepository
    private let conversationRepository: ConversationRepository
    private let sendMessageUseCase: SendMessageUseCase
    private let notificationMessageManager: MessageNotificationManager
    private let networkMonitor: NetworkMonitor
    private let blockedUserRepository: BlockedUserRepository
    
    @Published var uiState: ChatUiState = ChatUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private var messagesDict: [Int64:Message] = [:]
    private var conversation: Conversation
    private let currentUser: User?
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        conversation: Conversation,
        userRepository: UserRepository,
        messageRepository: MessageRepository,
        conversationRepository: ConversationRepository,
        sendMessageUseCase: SendMessageUseCase,
        notificationMessageManager: MessageNotificationManager,
        networkMonitor: NetworkMonitor,
        blockedUserRepository: BlockedUserRepository
    ) {
        self.conversation = conversation
        self.userRepository = userRepository
        self.messageRepository = messageRepository
        self.conversationRepository = conversationRepository
        self.sendMessageUseCase = sendMessageUseCase
        self.notificationMessageManager = notificationMessageManager
        self.networkMonitor = networkMonitor
        self.blockedUserRepository = blockedUserRepository
        
        currentUser = userRepository.currentUser
        getMessages(offset: 0)
        listenMessages()
        listenConversationChanges()
        listenBlockedUserIds()
        seeMessages()
        notificationMessageManager.clearNotifications(conversationId: conversation.id)
    }
    
    private func listenMessages() {
        messageRepository.messageChanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] change in
                var hasChanged = false
                
                change.inserted.forEach { message in
                    if message.conversationId == self?.conversation.id {
                        self?.messagesDict[message.id] = message
                        self?.seeMessage(message)
                        if !hasChanged {
                            hasChanged = true
                        }
                    }
                }
                
                change.updated.forEach { message in
                    if message.conversationId == self?.conversation.id {
                        self?.messagesDict[message.id] = message
                        self?.seeMessage(message)
                        if !hasChanged {
                            hasChanged = true
                        }
                    }
                }
                
                change.deleted.forEach { message in
                    if message.conversationId == self?.conversation.id {
                        self?.messagesDict.removeValue(forKey: message.id)
                        if !hasChanged {
                            hasChanged = true
                        }
                    }
                }
                
                if hasChanged {
                    self?.refreshMessages()
                }
            }.store(in: &cancellables)
    }
    
    func sendMessage() {
        guard !uiState.messageText.isEmpty, let currentUser else { return }
        
        let message = Message(
            id: GenerateIdUseCase.intId(),
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
                self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
            }
        }
    }
    
    func reportMessage(_ report: MessageReport) {
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: stringResource(.noInternetConectionError))
        }
        
        uiState.loading = true
        
        Task { @MainActor [weak self] in
            do {
                try await self?.messageRepository.reportMessage(report: report)
                self?.uiState.loading = false
            } catch {
                self?.uiState.loading = false
                self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
            }
        }
    }
    
    func onMessageTextChange(_ text: String) {
        if text.count <= MessageConstant.characterMax {
            uiState.messageText = text
        }
    }
    
    func unblockUser(userId: String) {
        guard let currentUserId = currentUser?.id else {
            return
        }
        
        uiState.loading = true
        
        Task { @MainActor [weak self] in
            do {
                try await self?.blockedUserRepository.unblockUser(
                    currentUserId: currentUserId,
                    userId: userId
                )
                self?.uiState.loading = false
            } catch {
                self?.uiState.loading = false
                self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
            }
        }
    }
    
    func deleteChat() {
        guard let currentUserId = currentUser?.id else {
            return
        }
        
        uiState.loading = true
        
        Task { @MainActor [weak self] in
            do {
                guard let conversation = self?.conversation else {
                    self?.uiState.loading = false
                    return
                }
                
                try await self?.conversationRepository.deleteConversation(
                    conversation: conversation,
                    userId: currentUserId,
                    deleteTime: Date()
                )
                try await self?.messageRepository.deleteLocalMessages(conversationId: conversation.id)
                self?.uiState.loading = false
                self?.event = MessageEvent.chatDeleted
            } catch {
                self?.uiState.loading = false
                self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
            }
        }
    }
    
    private func getMessages(offset: Int) {
        Task { @MainActor [weak self] in
            guard let conversation = self?.conversation else {
                return
            }
            guard let messages = try? await self?.messageRepository.getMessages(
                conversationId: conversation.id,
                offset: offset,
                limit: MessageConstant.loadLimit
            ) else {
                return
            }
            
            if !messages.isEmpty {
                messages.forEach { self?.messagesDict[$0.id] = $0 }
                self?.refreshMessages()
            } else {
                self?.uiState.canLoadMoreMessages = false
            }
        }
    }
    
    private func seeMessages() {
        guard let currentUser else { return }
        
        Task {
            try? await messageRepository.updateSeenMessages(
                conversationId: conversation.id,
                currentUserId: currentUser.id
            )
        }
    }
    
    private func seeMessage(_ message: Message) {
        if !message.seen && message.senderId == conversation.interlocutor.id {
            Task {
                try? await messageRepository.updateSeenMessage(message: message)
            }
        }
    }
    
    private func refreshMessages() {
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
        blockedUserRepository.blockedUserIds
            .receive(on: DispatchQueue.main)
            .sink { [weak self] blockedUserIds in
                self?.uiState.userBlocked = blockedUserIds.contains(interlocutorId)
            }.store(in: &cancellables)
    }
    
    struct ChatUiState {
        fileprivate(set) var messages: [Message] = []
        fileprivate(set) var messageText: String = ""
        fileprivate(set) var loading: Bool = false
        fileprivate(set) var userBlocked: Bool = false
        fileprivate(set) var canLoadMoreMessages: Bool = true
    }
    
    enum MessageEvent: SingleUiEvent {
        case chatDeleted
    }
}
