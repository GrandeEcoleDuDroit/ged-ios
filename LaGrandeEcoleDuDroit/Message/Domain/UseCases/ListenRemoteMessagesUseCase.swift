import Foundation
import Combine

class ListenRemoteMessagesUseCase {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    private let blockedUserRepository: BlockedUserRepository
    private let messageCancellablesQueue = DispatchQueue(label: "messageCancellablesQueue")

    private var messageCancellables: [String: AnyCancellable] = [:]
    private let tag = String(describing: ListenRemoteMessagesUseCase.self)
    
    init(
        userRepository: UserRepository,
        conversationRepository: ConversationRepository,
        messageRepository: MessageRepository,
        blockedUserRepository: BlockedUserRepository
    ) {
        self.userRepository = userRepository
        self.conversationRepository = conversationRepository
        self.messageRepository = messageRepository
        self.blockedUserRepository = blockedUserRepository
    }
    
    func start(conversation: Conversation) {
        messageCancellables[conversation.interlocutor.id]?.cancel()
        updateMessageCancellables(for: conversation)
    }
    
    func stop(userId: String) {
        messageCancellables[userId]?.cancel()
        messageCancellables.removeValue(forKey: userId)
    }
    
    func stopAll() {
        messageRepository.stopListeningMessages()
        messageCancellables.values.forEach { $0.cancel() }
        messageCancellables.removeAll()
    }
    
    private func updateMessageCancellables(for conversation: Conversation) {
        Task {                
            do {
                let blockedUserIds = blockedUserRepository.getLocalBlockedUserIds()
                
                if !blockedUserIds.contains(conversation.interlocutor.id) {
                    let cancellable = try await listenRemoteMessages(conversation)
                    messageCancellablesQueue.async {
                        self.messageCancellables[conversation.id] = cancellable
                    }
                }
            } catch {
                e(tag, "Failed to listen remote messages for conversation with \(conversation.interlocutor.fullName): \(error)", error)
            }
        }
    }
    
    private func listenRemoteMessages(_ conversation: Conversation) async throws -> AnyCancellable {
        let lastMessage = try await messageRepository.getLastMessage(conversationId: conversation.id)
        let offsetTime = getOffsetTime(conversation: conversation, lastMessage: lastMessage)
        
        return messageRepository.fetchRemoteMessages(conversation: conversation, offsetTime: offsetTime)
            .catch { error -> Empty<Message, Never> in
                e(self.tag, "Failed to fetch remote message with \(conversation.interlocutor.fullName): \(error)", error)
                return Empty(completeImmediately: true)
            }.sink { [weak self] message in
                Task {
                    try? await self?.messageRepository.upsertLocalMessage(message: message)
                }
            }
    }
        
    private func getOffsetTime(conversation: Conversation, lastMessage: Message?) -> Date? {
        [conversation.deleteTime, lastMessage?.date].compactMap { $0 }.max()
    }
}
