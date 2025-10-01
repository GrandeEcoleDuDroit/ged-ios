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
    
    func clear() {
        conversationsMessageSubject.value.removeAll()
        messageCancellables.forEach { $0.value.cancel() }
        messageCancellables.removeAll()
    }
    
    private func listen() {
        listenConversationValueChanges()
        listenConversationDeleteChanges()
    }
    
    private func listenConversationValueChanges() {
        let initial = getConversations()
        let updates = conversationRepository.conversationChanges.map { change in
            change.inserted + change.updated
        }
        
        Publishers.Merge(initial, updates)
            .sink { [weak self] conversations in
                for conversation in conversations {
                    self?.messageCancellables[conversation.id]?.cancel()
                    
                    let cancellable = self?.listenLastMessage(from: conversation)
                    
                    self?.messageCancellables[conversation.id] = cancellable
                }
            }.store(in: &conversationCancellables)
    }
    
    private func listenConversationDeleteChanges()  {
        conversationRepository.conversationChanges.map { change in
            change.deleted
        }.sink { [weak self] deletedConversations in
            for conversation in deletedConversations {
                self?.messageCancellables[conversation.id]?.cancel()
                self?.messageCancellables[conversation.id] = nil
                self?.conversationsMessageSubject.value[conversation.id] = nil
            }
        }.store(in: &conversationCancellables)
    }
    
    private func getConversations() -> Future<[Conversation], Never> {
        Future<[Conversation], Never> { promise in
            Task {
                let conversations = (try? await self.conversationRepository.getConversations()) ?? []
                promise(.success(conversations))
            }
        }
    }
    
    private func listenLastMessage(from conversation: Conversation) -> AnyCancellable {
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
            .sink { [weak self] message in
                guard let message = message else {
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
    
    private func listenLastMessageChanges(conversation: Conversation) -> AnyPublisher<(Message, Change), Never> {
        messageRepository.messageChanges
            .compactMap { change in
                let filteredDeletedMessages = change.deleted.filter { $0.conversationId == conversation.id }
                let lastDeletedMessage = filteredDeletedMessages.sorted { $0.date > $1.date }.first

                let combinedMessages = change.inserted + change.updated
                let filteredUpdatedMessages = combinedMessages.filter { $0.conversationId == conversation.id }
                let lastUpdatedMessage = filteredUpdatedMessages.sorted { $0.date > $1.date }.first

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
