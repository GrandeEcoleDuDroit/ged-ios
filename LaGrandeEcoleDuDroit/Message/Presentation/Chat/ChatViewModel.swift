import Foundation
import Combine

class ChatViewModel: ViewModel {
    private var conversation: Conversation
    private let userRepository: UserRepository
    private let messageRepository: MessageRepository
    private let conversationRepository: ConversationRepository
    private let sendMessageUseCase: SendMessageUseCase
    private let notificationMessageManager: MessageNotificationManager
    private let networkMonitor: NetworkMonitor
    private let blockedUserRepository: BlockedUserRepository
    
    @Published var uiState: ChatUiState = ChatUiState()
    @Published var event: SingleUiEvent? = nil
    private var cancellables: Set<AnyCancellable> = []
    private let user: User?
    private var offset: Int = 0
    
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
        
        user = userRepository.currentUser
        getMessages(offset: offset)
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
                        self?.uiState.messageMap[message.id] = nil
                    }
            }.store(in: &cancellables)
    }
    
    func sendMessage() {
        guard !uiState.messageText.isEmpty, let user else { return }
        
        let message = Message(
            id: GenerateIdUseCase.intId(),
            senderId: user.id,
            recipientId: conversation.interlocutor.id,
            conversationId: conversation.id,
            content: uiState.messageText,
            date: Date(),
            seen: false,
            state: .draft
        )
        
        Task {
            await sendMessageUseCase.execute(conversation: conversation, message: message, userId: user.id)
        }
        uiState.messageText = ""
    }
    
    func loadMoreMessages() {
        offset += 20
        getMessages(offset: offset)
    }
    
    func resendErrorMessage(_ message: Message) {
        guard let user else { return }
        
        Task {
            await sendMessageUseCase.execute(
                conversation: conversation,
                message: message.copy { $0.date = Date() },
                userId: user.id
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
            return event = ErrorEvent(message: getString(.noInternetConectionError))
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
    
    private func getMessages(offset: Int) {
        Task { @MainActor [weak self] in
            guard let conversation = self?.conversation else {
                return
            }
            guard let messages = try? await self?.messageRepository.getMessages(
                conversationId: conversation.id,
                offset: offset
            ) else {
                return
            }
            
            for message in messages {
                self?.uiState.messageMap[message.id] = message
                await sleep(0.1)
            }
        }
    }
    
    private func seeMessages() {
        guard let user else { return }
        
        Task {
            try? await messageRepository.updateSeenMessages(
                conversationId: conversation.id,
                userId: user.id
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
    
    private func addOrUpdateMessage(_ message: Message) {
        uiState.messageMap[message.id] = message
    }
    
    private func listenConversationChanges() {
        conversationRepository.conversationChanges.map { [weak self] in
            $0.updated.first { $0.id == self?.conversation.id }
        }
        .compactMap { $0 }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] updatedConversation in
            self?.conversation = updatedConversation
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
        fileprivate var messageMap: [Int64: Message] = [:]
        var messages: [Message] {
            messageMap.values.sorted { $0.date < $1.date }
        }
        var messageText: String = ""
        fileprivate(set) var loading: Bool = false
        fileprivate(set) var userBlocked: Bool = false
    }
}
