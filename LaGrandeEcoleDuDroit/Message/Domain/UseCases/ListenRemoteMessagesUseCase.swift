import Foundation
import Combine

private let tag = String(describing: ListenRemoteMessagesUseCase.self)

class ListenRemoteMessagesUseCase {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    private var fetchedConversations: [String: Conversation] = [:]
    private var cancellables = Set<AnyCancellable>()
    
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
        conversationsPublisher()
            .map { conversations in
                conversations.forEach { conversation in
                    self.fetchedConversations[conversation.id] = conversation
                }
                return conversations
            }
            .flatMap(messagePublisher)
            .sink { [weak self] message in
                Task { await self?.messageRepository.upsertLocalMessage(message: message) }
            }
            .store(in: &cancellables)
    }
    
    func stop() {
        messageRepository.stopListeningMessages()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        fetchedConversations.removeAll()
    }
    
    private func conversationsPublisher() -> AnyPublisher<[Conversation], Never> {
        let initial = getCurrentConversations()
        let updates = conversationRepository.conversationChanges.map { change in
            change.inserted + change.updated.filter { conversation in
                self.fetchedConversations[conversation.id] != conversation
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
    
    private func messagePublisher(for conversations: [Conversation]) -> AnyPublisher<Message, Never> {
        let publishers = conversations.map { conversation in
            self.getLastMessageDate(for: conversation.id)
                .flatMap { offsetTime in
                    self.remoteMessagePublisher(conversation: conversation, offsetTime: offsetTime)
                }
                .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(publishers)
            .eraseToAnyPublisher()
    }
    
    private func getLastMessageDate(for conversationId: String) -> Future<Date?, Never> {
        Future<Date?, Never> { promise in
            Task {
                let offset = await self.messageRepository.getLastMessageDate(conversationId: conversationId)
                promise(.success(offset))
            }
        }
    }
        
    private func remoteMessagePublisher(conversation: Conversation, offsetTime: Date?) -> AnyPublisher<Message, Never> {
        messageRepository
            .fetchRemoteMessages(conversation: conversation, offsetTime: offsetTime)
            .catch { error -> Empty<Message, Never> in
                e(tag, "Failed to fetch message: \(error)", error)
                return Empty(completeImmediately: true)
            }.eraseToAnyPublisher()
    }
}
