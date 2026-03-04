import Foundation

class UpdateConversationEffectiveFromUseCase {
    private let conversationRepository: ConversationRepository
    private let userRepository: UserRepository
    
    init(
        conversationRepository: ConversationRepository,
        userRepository: UserRepository
    ) {
        self.conversationRepository = conversationRepository
        self.userRepository = userRepository
    }
    
    func execute(userId: String, effectiveFrom: Date) async {
        guard let currentUserId = userRepository.currentUser?.id,
              let conversation = await conversationRepository.getLocalConversation(interlocutorId: userId)
        else { return }
        
        try? await conversationRepository.updateConversationEffectiveFrom(
            conversationId: conversation.id,
            currentUserId: currentUserId,
            effectiveFrom: effectiveFrom
        )
    }
}
