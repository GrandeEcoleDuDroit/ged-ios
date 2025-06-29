import Combine

class ConversationMessageRepositoryImpl: ConversationMessageRepository {
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    private var conversationCancellables: Set<AnyCancellable> = []
    private var messageCancellables: [String: AnyCancellable] = [:]
    private let conversationsMessageSubject = CurrentValueSubject<[String: ConversationMessage], Never>([:])
    var conversationsMessage: AnyPublisher<[String: ConversationMessage], Never> {
        conversationsMessageSubject.eraseToAnyPublisher()
    }

    init(
        conversationRepository: ConversationRepository,
        messageRepository: MessageRepository
    ) {
        self.conversationRepository = conversationRepository
        self.messageRepository = messageRepository
        listen()
    }
    
    func deleteConversationMessage(conversationId: String) {
        conversationsMessageSubject.value.removeValue(forKey: conversationId)
        messageCancellables[conversationId]?.cancel()
        messageCancellables.removeValue(forKey: conversationId)
    }
    
    func deleteAll() {
        conversationsMessageSubject.value.removeAll()
        messageCancellables.forEach { $0.value.cancel() }
        messageCancellables.removeAll()
    }
    
    private func listen() {
        listenConversations()
            .sink { [weak self] conversations in
                for conversation in conversations {
                    self?.messageCancellables[conversation.id]?.cancel()
                    
                    let cancellable = self?.updateConversationMessage(for: conversation)
                    
                    self?.messageCancellables[conversation.id] = cancellable
                }
            }.store(in: &conversationCancellables)
    }
    
    private func listenConversations() -> AnyPublisher<[Conversation], Never> {
        let initial = getConversations()
        let updates = conversationRepository.conversationChanges.map { change in
            change.inserted + change.updated
        }
        
        return Publishers.Merge(initial, updates)
            .eraseToAnyPublisher()
    }
    
    private func getConversations() -> Future<[Conversation], Never> {
        Future<[Conversation], Never> { promise in
            Task {
                let conversations = (try? await self.conversationRepository.getConversations()) ?? []
                promise(.success(conversations))
            }
        }
    }
    
    private func updateConversationMessage(for conversation: Conversation) -> AnyCancellable {
        listenLastMessage(from: conversation)
            .sink { [weak self] message in
                guard let message = message else {
                    self?.conversationsMessageSubject.value.removeValue(forKey: conversation.id)
                    return
                }
                
                self?.conversationsMessageSubject.value[conversation.id] =
                    ConversationMessage(conversation: conversation, lastMessage: message)
            }
    }
    
    private func listenLastMessage(from conversation: Conversation) -> AnyPublisher<Message?, Never> {
        let initial = getLastMessage(conversation: conversation)
        
        let update = listenLastMessageChanges(conversation: conversation).flatMap { (message, change) in
            if change == .deleted {
                return self.getLastMessage(conversation: conversation).eraseToAnyPublisher()
            } else {
                return Just(message).eraseToAnyPublisher()
            }
        }
        
        return initial
            .append(update)
            .eraseToAnyPublisher()
    }
    
    private func getLastMessage(conversation: Conversation) -> Future<Message?, Never> {
        Future<Message?, Never> { promise in
            Task {
                let message = try? await self.messageRepository.getLastMessage(conversationId: conversation.id)
                promise(.success(message))
            }
        }
    }
    
    private func listenLastMessageChanges(conversation: Conversation) -> AnyPublisher<(Message, Change), Never> {
        messageRepository.messageChanges
            .compactMap { change in
                let filteredDeletedMessages = change.deleted.filter { $0.conversationId == conversation.id }
                let lastDeletedMessage = filteredDeletedMessages.sorted { $0.date > $1.date }.first

                let combinedMessages = change.inserted + change.updated
                let filteredUpdatedMessages = combinedMessages.filter { $0.conversationId == conversation.id }
                let lastUpdatedMessage = filteredUpdatedMessages.sorted { $0.date > $1.date }.first

                return if let deleted = lastDeletedMessage, let updated = lastUpdatedMessage {
                    deleted.date > updated.date ? (deleted, .deleted) : (updated, .updated)
                } else if let deleted = lastDeletedMessage {
                    (deleted, .deleted)
                } else if let updated = lastUpdatedMessage {
                    (updated, .updated)
                } else {
                    nil
                }
            }
            .eraseToAnyPublisher()
    }
}
