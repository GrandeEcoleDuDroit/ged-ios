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
        let deleteTime = Date()
        let updatedConversation = conversation.copy { $0.deleteTime = deleteTime }
        
        try await conversationRepository.updateLocalConversation(conversation: updatedConversation.copy { $0.state = .deleting })
        try await conversationRepository.deleteConversation(conversation: updatedConversation, userId: userId, deleteTime: deleteTime)
        try await messageRepository.deleteLocalMessages(conversationId: updatedConversation.id)
    }
}
