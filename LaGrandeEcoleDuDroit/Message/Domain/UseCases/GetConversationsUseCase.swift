import Combine

class GetConversationsUseCase {
    private let userConversationRepository: UserConversationRepository
    
    init(userConversationRepository: UserConversationRepository) {
        self.userConversationRepository = userConversationRepository
    }
    
    func execute() -> AnyPublisher<ConversationUser, Error> {
        userConversationRepository.getUserConversations()
    }
    
    func stop() {
        userConversationRepository.stopGettingUserConversations()
    }
}
