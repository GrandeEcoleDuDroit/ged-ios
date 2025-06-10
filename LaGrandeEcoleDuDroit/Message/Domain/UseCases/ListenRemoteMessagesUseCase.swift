import Foundation
import Combine

class ListenRemoteMessagesUseCase {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    private var fetchedConversations: [String: Conversation] = [:]
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
            .map(updateFetchedConversations)
            .flatMap(launchMessagePublisher)
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
    
    private func listenConversationsPublisher() -> AnyPublisher<[Conversation], Never> {
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
    
    private func updateFetchedConversations(_ conversations: [Conversation]) -> [Conversation] {
        conversations.forEach { conversation in
            self.fetchedConversations[conversation.id] = conversation
        }
        return conversations
    }
    
    private func launchMessagePublisher(for conversations: [Conversation]) -> AnyPublisher<Message, Never> {
        let publishers = conversations.map { conversation in
            self.getLastMessageDate(for: conversation.id)
                .map { messageDate in
                    self.getMessageOffsetTime(
                        lastMessaegDate: messageDate,
                        conversationDeleteTime: conversation.deleteTime
                    )
                }
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
    
    private func getMessageOffsetTime(lastMessaegDate: Date?, conversationDeleteTime: Date?) -> Date? {
        if let deleteTime = conversationDeleteTime,
            let messageDate = lastMessaegDate,
            deleteTime > messageDate
        {
            deleteTime
        } else {
            lastMessaegDate
        }
    }
        
        
    private func remoteMessagePublisher(conversation: Conversation, offsetTime: Date?) -> AnyPublisher<Message, Never> {
        messageRepository.fetchRemoteMessages(conversation: conversation, offsetTime: offsetTime)
            .catch { error -> Empty<Message, Never> in
                e(self.tag, "Failed to fetch message: \(error)", error)
                return Empty(completeImmediately: true)
            }.eraseToAnyPublisher()
    }
}
