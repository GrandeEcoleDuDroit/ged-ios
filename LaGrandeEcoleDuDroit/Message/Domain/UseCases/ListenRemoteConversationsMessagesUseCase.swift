import Foundation
import Combine

private let tag = String(describing: ListenRemoteConversationsMessagesUseCase.self)

class ListenRemoteConversationsMessagesUseCase {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    private var cancellables = Set<AnyCancellable>()
    private var messageListeningJobs = [String: MessageListeningJob]()
    
    init(
        userRepository: UserRepository,
        conversationRepository: ConversationRepository,
        messageRepository: MessageRepository
    ) {
        self.userRepository = userRepository
        self.conversationRepository = conversationRepository
        self.messageRepository = messageRepository
    }
    
    func start() {
        stop()
        
        userRepository.user
            .flatMap { user in
                self.conversationRepository
                    .fetchRemoteConversations(userId: user.id)
                    .catch { error -> Empty<Conversation, Never> in
                        e("ConversationFetch", "Failed to fetch conversations: \(error)", error)
                        return Empty(completeImmediately: true)
                    }
            }
            .sink { completion in
                if case let .failure(error) = completion {
                    e(tag, "Failed to fetch remote conversations: \(error)", error)
                }
            } receiveValue: { [weak self] conversation in
                if self?.messageListeningJobs[conversation.id]?.conversation != conversation {
                    Task { try? await self?.conversationRepository.upsertLocalConversation(conversation: conversation) }
                    self?.updateMessageListeningJobs(conversation: conversation)
                }
            }
            .store(in: &cancellables)
    }
    
    func stop() {
        for (_, job) in messageListeningJobs {
            job.cancellable.cancel()
        }
        messageListeningJobs.removeAll()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    private func updateMessageListeningJobs(conversation: Conversation) {
        messageListeningJobs[conversation.id]?.cancellable.cancel()
        
        let cancellable = messageRepository
            .fetchRemoteMessages(conversationId: conversation.id, offsetTime: conversation.deleteTime)
            .sink { completion in
                if case let .failure(error) = completion {
                    e(tag, "Failed to fetch messages: \(error)", error)
                }
            } receiveValue: { [weak self] message in
                Task {
                    try? await self?.messageRepository.upsertLocalMessage(message: message)
                }
            }
        
        messageListeningJobs[conversation.id] = MessageListeningJob(conversation: conversation, cancellable: cancellable)
    }
}

private struct MessageListeningJob {
    let conversation: Conversation
    let cancellable: AnyCancellable
}
