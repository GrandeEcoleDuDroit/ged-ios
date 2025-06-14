import Foundation
import Combine

class ListenRemoteMessagesUseCase {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    private var messageCancellables: [String: MessageCancellable] = [:]
    private var cancellables = Set<AnyCancellable>()
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
    
    func start() {
        listenConversationsPublisher()
            .sink { [weak self] conversations in
                self?.handleConversationsUpdate(conversations)
            }
            .store(in: &cancellables)
    }
    
    func stop() {
        messageRepository.stopListeningMessages()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        messageCancellables.values.forEach { $0.cancellable.cancel() }
        messageCancellables.removeAll()
    }
    
    private func listenConversationsPublisher() -> AnyPublisher<[Conversation], Never> {
        let initial = getCurrentConversations()
        let updates = conversationRepository.conversationChanges.map { change in
            change.inserted + change.updated.filter { conversation in
                self.messageCancellables[conversation.id]?.conversation != conversation
            }
        }
        
        return Publishers.Merge(initial, updates)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    private func getCurrentConversations() -> Future<[Conversation], Never> {
        Future<[Conversation], Never> { promise in
            Task {
                let conversations = await self.conversationRepository.getConversations()
                promise(.success(conversations))
            }
        }
    }
    
    private func handleConversationsUpdate(_ conversations: [Conversation]) {
        for conversation in conversations {
            messageCancellables[conversation.id]?.cancellable.cancel()

            if let cancellable = subscribeToMessages(for: conversation) {
                messageCancellables[conversation.id] = MessageCancellable(
                    conversation: conversation,
                    cancellable: cancellable
                )
            }
        }
    }
    
    private func subscribeToMessages(for conversation: Conversation) -> Cancellable? {
        getLastMessage(for: conversation.id)
            .map { [weak self] message in
                self?.getOffsetTime(conversation: conversation, lastMessage: message)
            }
            .flatMap { [weak self] offsetTime in
                self?.remoteMessagePublisher(conversation: conversation, offsetTime: offsetTime)
                    ?? Empty().eraseToAnyPublisher()
            }
            .sink { [weak self] message in
                Task {
                    await self?.messageRepository.upsertLocalMessage(message: message)
                }
            }
    }
    
    private func getLastMessage(for conversationId: String) -> Future<Message?, Never> {
        Future<Message?, Never> { promise in
            Task {
                let offset = await self.messageRepository.getLastMessage(conversationId: conversationId)
                promise(.success(offset))
            }
        }
    }
    
    private func getOffsetTime(conversation: Conversation, lastMessage: Message?) -> Date? {
        if let deleteTime = conversation.deleteTime,
           let messageDate = lastMessage?.date,
            deleteTime > messageDate
        {
            deleteTime
        } else {
            lastMessage?.date
        }
    }
        
        
    private func remoteMessagePublisher(
        conversation: Conversation,
        offsetTime: Date?
    ) -> AnyPublisher<Message, Never> {
        messageRepository.fetchRemoteMessages(conversation: conversation, offsetTime: offsetTime)
            .catch { error -> Empty<Message, Never> in
                e(self.tag, "Failed to fetch message: \(error)", error)
                return Empty(completeImmediately: true)
            }.eraseToAnyPublisher()
    }
    
    private struct MessageCancellable {
        let conversation: Conversation
        let cancellable: any Cancellable
    }
}
