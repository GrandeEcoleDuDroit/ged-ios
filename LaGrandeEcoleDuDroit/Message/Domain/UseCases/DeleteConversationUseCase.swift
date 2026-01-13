import Foundation

class DeleteConversationUseCase {
    private let conversationRepository: ConversationRepository
    private let messageRepository: MessageRepository
    private let conversationMessageRepository: ConversationMessageRepository
    
    init(
        conversationRepository: ConversationRepository,
        messageRepository: MessageRepository,
        conversationMessageRepository: ConversationMessageRepository
    ) {
        self.conversationRepository = conversationRepository
        self.messageRepository = messageRepository
        self.conversationMessageRepository = conversationMessageRepository
    }
    
    func execute(conversation: Conversation, userId: String) async throws {
        switch conversation.state {
            case .created:
                let deleteTime = Date()
                let updatedConversation = conversation.copy { $0.effectiveFrom = deleteTime }
                
                try await conversationRepository.updateLocalConversation(conversation: updatedConversation.copy { $0.state = .deleting })
                try await conversationRepository.deleteConversation(conversationId: updatedConversation.id, userId: userId, date: deleteTime)
                try await messageRepository.deleteLocalMessages(conversationId: updatedConversation.id)
                
            default:
                try await conversationRepository.deleteLocalConversation(conversationId: conversation.id)
                try await messageRepository.deleteLocalMessages(conversationId: conversation.id)
        }
    }
}
