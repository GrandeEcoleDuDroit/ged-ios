import Foundation
import Combine

private let tag = String(describing: ListenRemoteMessagesUseCase.self)

class ListenRemoteMessagesUseCase {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    private var cancellables = Set<AnyCancellable>()
    private var conversations = Set<Conversation>()
    
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
        conversationRepository.conversations
            .map { conversations in
                conversations.values.filter {
                    !self.conversations.contains($0)
                }.map { conversation in
                    self.conversations.insert(conversation)
                    return conversation
                }
            }
            .flatMap { conversations in
                Publishers.MergeMany(
                    conversations.map { conversation in
                        self.getMessageOffsetTime(for: conversation.id)
                            .flatMap { offsetTime in
                                self.getRemoteMessage(conversationId: conversation.id, offsetTime: offsetTime)
                                    .map { message in (conversation: conversation, message: message) }
                            }
                    }
                )
            }
            .sink { [weak self] (conversation, message) in
                Task {
                    await self?.messageRepository.upsertLocalMessage(message: message)
                    if message.senderId == conversation.interlocutor.id {
                        await self?.updateLocalSeenMessage(conversationId: conversation.id)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func stop() {
        messageRepository.stopListeningMessages()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    private func getMessageOffsetTime(for conversationId: String) -> Future<Date?, Never> {
        Future<Date?, Never> { promise in
            Task {
                let offset = await self.messageRepository.getLastMessageDate(conversationId: conversationId)
                promise(.success(offset))
            }
        }
    }
        
    private func getRemoteMessage(conversationId: String, offsetTime: Date?) -> AnyPublisher<Message, Never> {
        messageRepository
            .fetchRemoteMessages(conversationId: conversationId, offsetTime: offsetTime)
            .catch { error -> Empty<Message, Never> in
                e(tag, "Failed to fetch message: \(error)", error)
                return Empty(completeImmediately: true)
            }.eraseToAnyPublisher()
    }
    
    private func updateLocalSeenMessage(conversationId: String) async {
        try? await messageRepository.updateLocalSeenMessages(conversationId: conversationId)
    }
}
