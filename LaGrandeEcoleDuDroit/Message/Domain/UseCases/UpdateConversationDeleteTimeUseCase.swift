import Foundation

class UpdateConversationDeleteTimeUseCase {
    private let conversationRepository: ConversationRepository
    private let userRepository: UserRepository
    
    init(
        conversationRepository: ConversationRepository,
        userRepository: UserRepository
    ) {
        self.conversationRepository = conversationRepository
        self.userRepository = userRepository
    }
    
    func execute(userId: String, deleteTime: Date) async throws {
        guard let currentUserId = userRepository.currentUser?.id else {
            return
        }
        
        guard var conversation = try? await conversationRepository.getLocalConversation(interlocutorId: userId) else {
            return
        }
        
        conversation.deleteTime = deleteTime
        try? await conversationRepository.updateConversationDeleteTime(conversation: conversation, currentUserId: currentUserId)
    }
}
