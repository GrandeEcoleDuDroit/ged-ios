import Combine

class GetConversationsUseCase {
    private let conversationLocalRepository: ConversationLocalRepository
    
    init(conversationLocalRepository: ConversationLocalRepository) {
        self.conversationLocalRepository = conversationLocalRepository
    }
    
    func execute() -> AnyPublisher<[Conversation], Never> {
        conversationLocalRepository.conversations
    }
}
