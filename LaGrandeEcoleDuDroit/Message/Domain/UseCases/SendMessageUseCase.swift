import Foundation

class SendMessageUseCase {
    private let messageRepository: MessageRepository
    private let conversationRepository: ConversationRepository
    private let networkMonitor: NetworkMonitor
    
    init(
        messageRepository: MessageRepository,
        conversationRepository: ConversationRepository,
        networkMonitor: NetworkMonitor
    ) {
        self.messageRepository = messageRepository
        self.conversationRepository = conversationRepository
        self.networkMonitor = networkMonitor
    }
    
    func execute(conversation: Conversation, message: Message, userId: String) {
        Task {
            do {
                try await createDataLocally(conversation: conversation, message: message)
                try await createDataRemotely(conversation: conversation, message: message, userId: userId)
            } catch {
                if conversation.state == .draft {
                    try await conversationRepository.updateLocalConversation(conversation: conversation.with(state: .error))
                }
                try await messageRepository.upsertLocalMessage(message: message.with(state: .error))
            }
        }
    }
    
    private func createDataLocally(conversation: Conversation, message: Message) async throws {
        if conversation.state == .draft {
            try await conversationRepository.createLocalConversation(conversation: conversation.with(state: .creating))
        }
        
        if message.state == .draft {
            try await messageRepository.createLocalMessage(message: message.with(state: .sending))
        }
    }
    
    private func createDataRemotely(conversation: Conversation, message: Message, userId: String) async throws {
        if conversation.shouldBeCreated() {
            try await conversationRepository.createRemoteConversation(conversation: conversation,userId: userId)
        }
        try await messageRepository.createRemoteMessage(message: message)
    }
}
