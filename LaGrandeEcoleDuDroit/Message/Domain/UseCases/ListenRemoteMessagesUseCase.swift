import Foundation
import Combine

private let tag = String(describing: ListenRemoteMessagesUseCase.self)

class ListenRemoteMessagesUseCase {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    private let blockedUserRepository: BlockedUserRepository

    private let messageCancellable: MessageCancellable = MessageCancellable()
    
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
        Task {
            await messageCancellable.cancelAndRemove(forKey: conversation.id)
            updateMessageCancellables(for: conversation)
        }
    }
    
    func stop(userId: String) {
        Task {
            await messageCancellable.cancelAndRemove(forKey: userId)
        }
    }
    
    func stopAll() {
        messageRepository.stopListeningMessages()
        Task {
            await messageCancellable.cancelAll()
        }
    }
    
    private func updateMessageCancellables(for conversation: Conversation) {
        Task {
            do {
                let blockedUserIds = blockedUserRepository.currentBlockedUserIds
                
                if !blockedUserIds.contains(conversation.interlocutor.id) {
                    let cancellable = try await listenRemoteMessagesCancellable(conversation)
                    await messageCancellable.set(cancellable, forKey: conversation.id)
                }
            } catch {
                e(tag, "Failed to listen remote messages for conversation with \(conversation.interlocutor.fullName)", error)
            }
        }
    }
    
    private func listenRemoteMessagesCancellable(_ conversation: Conversation) async throws -> AnyCancellable {
        let lastMessage = try await messageRepository.getLastMessage(conversationId: conversation.id)
        let offsetTime = getOffsetTime(conversation: conversation, lastMessage: lastMessage)
        
        return messageRepository.fetchRemoteMessages(conversation: conversation, offsetTime: offsetTime)
            .catch { error in
                e(tag, "Failed to fetch remote message with \(conversation.interlocutor.fullName)", error)
                return Empty<Message, Never>()
            }
            .sink { [weak self] message in
                Task {
                    try? await self?.messageRepository.upsertLocalMessage(message: message)
                }
            }
    }
        
    private func getOffsetTime(conversation: Conversation, lastMessage: Message?) -> Date? {
        [conversation.deleteTime, lastMessage?.date].compactMap { $0 }.max()
    }
}

private actor MessageCancellable {
    private var cancellables: [String: AnyCancellable] = [:]

    func set(_ cancellable: AnyCancellable, forKey key: String) {
        cancellables[key] = cancellable
    }
    
    func cancelAndRemove(forKey key: String) {
        cancellables[key]?.cancel()
        cancellables.removeValue(forKey: key)
    }
    
    func cancelAll() {
        cancellables.values.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
