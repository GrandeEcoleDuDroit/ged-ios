import Foundation
class SendMessageUseCase {
    private let messageRepository: MessageRepository
    private let conversationRepository: ConversationRepository
    
    init(messageRepository: MessageRepository, conversationRepository: ConversationRepository) {
        self.messageRepository = messageRepository
        self.conversationRepository = conversationRepository
    }
    
    func execute(conversation: Conversation, user: User, content: String) {
        let message = newMessage(conversation: conversation, user: user, content: content)
        Task {
            if (conversation.shouldBeCreated()) {
                await createConversation(conversation: conversation, userId: user.id)
            }
            await createMessage(message: message)
        }
    }
    
    private func createConversation(conversation: Conversation, userId: String) async {
        do {
            try await conversationRepository.upsertLocalConversation(conversation: conversation.with(state: .loading))
            try await conversationRepository.createConversation(conversation: conversation, userId: userId)
        } catch {
            try? await conversationRepository.updateLocalConversation(conversation: conversation.with(state: .error))
        }
    }
    
    private func createMessage(message: Message) async {
        do {
            try await messageRepository.upsertLocalMessage(message: message.with(state: .loading))
            try await messageRepository.createMessage(message: message.with(state: .sent))
        } catch {
            try? await messageRepository.upsertLocalMessage(message: message.with(state: .error))
        }
    }
    
    private func newMessage(conversation: Conversation, user: User, content: String) -> Message {
        Message(
            id: GenerateIdUseCase.intId(),
            senderId: user.id,
            recipientId: conversation.interlocutor.id,
            conversationId: conversation.id,
            content: content,
            date: Date(),
            seen: false,
            state: .draft
        )
    }
}
