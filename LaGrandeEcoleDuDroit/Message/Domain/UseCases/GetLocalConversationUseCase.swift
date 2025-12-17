import Foundation

class GetLocalConversationUseCase {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    
    init(
        userRepository: UserRepository,
        conversationRepository: ConversationRepository
    ) {
        self.userRepository = userRepository
        self.conversationRepository = conversationRepository
    }
    
    func execute(interlocutor: User) async throws -> Conversation {
        if let conversation = try await conversationRepository.getLocalConversation(interlocutorId: interlocutor.id) {
            return conversation
        }
        
        if let user = userRepository.currentUser {
            return generateNewConversation(userId: user.id, interlocutor: interlocutor)
        } else {
            throw UserError.currentUserNotFound
        }
    }

    
    private func generateNewConversation(userId: String, interlocutor: User) -> Conversation {
        let conversationId = if (userId > interlocutor.id) {
            "\(userId)_\(interlocutor.id)"
        } else {
            "\(interlocutor.id)_\(userId)"
        }
        
        return Conversation(
            id: conversationId,
            interlocutor: interlocutor,
            createdAt: Date(),
            state: .draft,
            deleteTime: nil
        )
    }
}
