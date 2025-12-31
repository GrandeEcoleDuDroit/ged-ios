import Foundation
import Combine

private let tag = String(describing: ListenRemoteMessagesUseCase.self)

class ListenRemoteMessagesUseCase {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    private let blockedUserRepository: BlockedUserRepository

    private let messageCancellableActor = MessageCancellableActor()
    
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
            await messageCancellableActor.cancelAndRemove(conversationId: conversation.id)
            updateMessageCancellables(conversation: conversation)
        }
    }
    
    func stop(conversationId: String) {
        Task {
            await messageCancellableActor.cancelAndRemove(conversationId: conversationId)
        }
    }
    
    func stopAll() {
        messageRepository.stopListeningMessages()
        Task {
            await messageCancellableActor.cancelAll()
        }
    }
    
    private func updateMessageCancellables(conversation: Conversation) {
        Task {
            do {
                let blockedUserIds = blockedUserRepository.currentBlockedUserIds
                
                if !blockedUserIds.contains(conversation.interlocutor.id) {
                    let cancellable = try await listenRemoteMessagesCancellable(conversation)
                    await messageCancellableActor.set(cancellable, conversationId: conversation.id)
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
        [conversation.effectiveFrom, lastMessage?.date].compactMap { $0 }.max()
    }
}

private actor MessageCancellableActor {
    private var cancellables: [String: AnyCancellable] = [:]

    func set(_ cancellable: AnyCancellable, conversationId: String) {
        cancellables[conversationId] = cancellable
    }
    
    func cancelAndRemove(conversationId: String) {
        cancellables[conversationId]?.cancel()
        cancellables.removeValue(forKey: conversationId)
    }
    
    func cancelAll() {
        cancellables.values.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
