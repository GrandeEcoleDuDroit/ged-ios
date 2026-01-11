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
            updateMessageCancellable(conversation: conversation)
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
    
    private func updateMessageCancellable(conversation: Conversation) {
        guard let currentUser = userRepository.currentUser else { return }
        Task {
            do {
                let cancellable = try await listenRemoteMessagesCancellable(userId: currentUser.id, conversation: conversation)
                await messageCancellableActor.set(cancellable, conversationId: conversation.id)
            } catch {
                e(tag, "Error updating message cancellable for conversation \(conversation.id)", error)
            }
        }
    }
    
    private func listenRemoteMessagesCancellable(userId: String, conversation: Conversation) async throws -> AnyCancellable {
        let lastMessage = try await messageRepository.getLastMessage(conversationId: conversation.id)
        let offsetTime = getOffsetTime(conversation: conversation, lastMessage: lastMessage)
        
        return messageRepository.fetchRemoteMessages(userId: userId, conversation: conversation, offsetTime: offsetTime)
            .catch { error in
                e(tag, "Error fetching remote message for conversation \(conversation.id)", error)
                return Empty<Message, Never>()
            }
            .filter { $0.visible }
            .sink { [weak self] message in
                let blockedUsers = self?.blockedUserRepository.currentBlockedUsers
                let hideMessage = blockedUsers?[message.senderId].map { message.date > $0.date } ?? false
                
                Task {
                    do {
                        if hideMessage {
                            try await self?.messageRepository.updateMessageVisibility(message: message, currentUserId: userId, visible: false)
                        } else {
                            try? await self?.messageRepository.upsertLocalMessage(message: message)
                        }
                    } catch {
                        e(tag, "Error updating message visibility", error)
                    }
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
