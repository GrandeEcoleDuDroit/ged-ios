import Foundation
class SendMessageUseCase {
    private let messageRepository: MessageRepository
    private let conversationRepository: ConversationRepository
    
    init(messageRepository: MessageRepository, conversationRepository: ConversationRepository) {
        self.messageRepository = messageRepository
        self.conversationRepository = conversationRepository
    }
    
    func execute(message: Message, conversation: Conversation, userId: String) {
        Task {
            if (conversation.shouldBeCreated()) {
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
}
