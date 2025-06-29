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
    
    func execute(conversation: Conversation, userId: String) {
        let deleteTime = Date()
        let updatedConversation = conversation.with(deleteTime: deleteTime)
        Task {
            try await conversationRepository.updateLocalConversation(conversation: updatedConversation.with(state: .deleting))
            try await conversationRepository.deleteConversation(conversation: updatedConversation, userId: userId, deleteTime: deleteTime)
            try await messageRepository.deleteLocalMessages(conversationId: updatedConversation.id)
            conversationMessageRepository.deleteConversationMessage(conversationId: updatedConversation.id)
        }
    }
}
