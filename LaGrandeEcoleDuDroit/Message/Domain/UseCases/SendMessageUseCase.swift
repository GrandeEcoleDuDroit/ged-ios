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
    
    func execute(message: Message, conversation: Conversation, userId: String) {
        Task {
            if (shouldCreateConversation(conversation: conversation)) {
                await createConversation(conversation: conversation, userId: userId)
            }
            await createMessage(message: message)
        }
    }
    
    private func createConversation(conversation: Conversation, userId: String) async {
        do {
            try await conversationRepository.createConversation(conversation:  conversation.with(state: .loading), userId: userId)
            await conversationRepository.updateLocalConversation(conversation: conversation.with(state: .created))
        } catch {
            await conversationRepository.updateLocalConversation(conversation: conversation.with(state: .error))
        }
    }
    
    private func createMessage(message: Message) async {
        do {
            try await messageRepository.createMessage(message: message.with(state: .loading))
            await messageRepository.updateLocalMessage(message: message.with(state: .sent))
        } catch {
            await messageRepository.updateLocalMessage(message: message.with(state: .error))
        }
    }
    
    private func shouldCreateConversation(conversation: Conversation) -> Bool {
        conversation.state == .draft ||
        conversation.state == .error ||
        (
            conversation.state == .loading &&
            conversation.createdAt.timeIntervalSinceNow < -10 &&
            networkMonitor.isConnected
        )
    }
}
