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
    
    func deleteConversationMessage() {
        conversationsMessageSubject.value.removeAll()
        messageCancellables.forEach { $0.value.cancel() }
        messageCancellables.removeAll()
    }
    
    private func listen() {
        listenConversationUpdates()
        listenConversationDeletions()
    }
    
    private func listenConversationUpdates() {
        let initial = getLocalConversations()
        let updates = conversationRepository.conversationChanges.map { $0.inserted + $0.updated }
        
        Publishers.Merge(initial, updates)
            .sink { [weak self] conversations in
                for conversation in conversations {
                    self?.messageCancellables[conversation.id]?.cancel()
                    let cancellable = self?.listenLastMessage(from: conversation)
                    self?.messageCancellables[conversation.id] = cancellable
                }
            }.store(in: &conversationCancellables)
    }
    
    private func listenConversationDeletions()  {
        conversationRepository.conversationChanges
            .map { $0.deleted }
            .sink { [weak self] deletedConversations in
                for conversation in deletedConversations {
                    self?.messageCancellables[conversation.id]?.cancel()
                    self?.messageCancellables[conversation.id] = nil
                    self?.conversationsMessageSubject.value[conversation.id] = nil
                }
            }.store(in: &conversationCancellables)
    }
    
    private func getLocalConversations() -> Future<[Conversation], Never> {
        Future<[Conversation], Never> { promise in
            Task {
                let conversations = await self.conversationRepository.getLocalConversations()
                promise(.success(conversations))
            }
        }
    }
    
    private func listenLastMessage(from conversation: Conversation) -> AnyCancellable {
        let initial = getLastMessage(conversation: conversation)
        let updates = listenLastMessageUpdates(conversation: conversation).flatMap { (message, change) in
            if change == .deleted {
                return self.getLastMessage(conversation: conversation).eraseToAnyPublisher()
            } else {
                return Just(message).eraseToAnyPublisher()
            }
        }
        
        return initial
            .append(updates)
            .sink { [weak self] message in
                guard let message else {
                    self?.conversationsMessageSubject.value[conversation.id] = nil
                    return
                }
                
                self?.conversationsMessageSubject.value[conversation.id] =
                    ConversationMessage(conversation: conversation, lastMessage: message)
            }
    }
    
    private func getLastMessage(conversation: Conversation) -> Future<Message?, Never> {
        Future<Message?, Never> { promise in
            Task {
                let message = try? await self.messageRepository.getLastMessage(conversationId: conversation.id)
                promise(.success(message))
            }
        }
    }
    
    private func listenLastMessageUpdates(conversation: Conversation) -> AnyPublisher<(Message, Change), Never> {
        messageRepository.messageChanges
            .compactMap { change in
                let deletedMessages = change.deleted.filter { $0.conversationId == conversation.id }
                let updatedMessages = (change.inserted + change.updated).filter { $0.conversationId == conversation.id }
                
                let lastDeletedMessage = deletedMessages.sorted { $0.date > $1.date }.first
                let lastUpdatedMessage = updatedMessages.sorted { $0.date > $1.date }.first

                return if let lastDeletedMessage, let lastUpdatedMessage {
                    if lastDeletedMessage.date > lastUpdatedMessage.date {
                        (lastDeletedMessage, .deleted)
                    } else {
                        (lastUpdatedMessage, .updated)
                    }
                } else if let lastDeletedMessage {
                    (lastDeletedMessage, .deleted)
                } else if let lastUpdatedMessage {
                    (lastUpdatedMessage, .updated)
                } else {
                    nil
                }
            }
            .eraseToAnyPublisher()
    }
}
