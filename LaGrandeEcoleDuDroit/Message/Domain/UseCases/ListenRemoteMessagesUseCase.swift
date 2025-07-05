import Foundation
import Combine

class ListenRemoteMessagesUseCase {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    private var messageCancellables: [String: MessageCancellable] = [:]
    private let tag = String(describing: ListenRemoteMessagesUseCase.self)
    
    init(
        userRepository: UserRepository,
        conversationRepository: ConversationRepository,
        messageRepository: MessageRepository
    ) {
        self.userRepository = userRepository
        self.conversationRepository = conversationRepository
        self.messageRepository = messageRepository
    }
    
    func start(conversation: Conversation) {
        listenRemoteMessages(conversation)
    }
    
    func stop() {
        messageRepository.stopListeningMessages()
        messageCancellables.values.forEach { $0.cancellable.cancel() }
        messageCancellables.removeAll()
    }
    
    private func listenRemoteMessages(_ conversation: Conversation) {
        guard messageCancellables[conversation.id]?.conversation != conversation else {
            return
        }
        
        messageCancellables[conversation.id]?.cancellable.cancel()

        let cancellable = upsertMessagesFromRemote(for: conversation)
        
        messageCancellables[conversation.id] = MessageCancellable(
            conversation: conversation,
            cancellable: cancellable
        )
    }
    
    private func upsertMessagesFromRemote(for conversation: Conversation) -> Cancellable {
        getLastMessage(for: conversation.id)
            .map { [weak self] message in
                self?.getOffsetTime(conversation: conversation, lastMessage: message)
            }
            .flatMap { [weak self] offsetTime in
                self?.fetchRemoteMessage(conversation: conversation, offsetTime: offsetTime)
                    ?? Empty().eraseToAnyPublisher()
            }
            .map {
                $0.map { message in
                    message.with(state: .sent)
                }
            }
            .sink { [weak self] messages in
                Task {
                    try? await self?.messageRepository.upsertLocalMessages(messages: messages)
                }
            }
    }
    
    private func getLastMessage(for conversationId: String) -> Future<Message?, Never> {
        Future<Message?, Never> { promise in
            Task {
                let offset = try? await self.messageRepository.getLastMessage(conversationId: conversationId)
                promise(.success(offset))
            }
        }
    }
    
    private func getOffsetTime(conversation: Conversation, lastMessage: Message?) -> Date? {
        [conversation.deleteTime, lastMessage?.date]
            .compactMap { $0 }
            .max()
    }
        
        
    private func fetchRemoteMessage(
        conversation: Conversation,
        offsetTime: Date?
    ) -> AnyPublisher<[Message], Never> {
        messageRepository.fetchRemoteMessages(conversation: conversation, offsetTime: offsetTime)
            .catch { error -> Empty<[Message], Never> in
                e(self.tag, "Failed to fetch message: \(error)", error)
                return Empty(completeImmediately: true)
            }.eraseToAnyPublisher()
    }
    
    private struct MessageCancellable {
        let conversation: Conversation
        let cancellable: any Cancellable
    }
}
