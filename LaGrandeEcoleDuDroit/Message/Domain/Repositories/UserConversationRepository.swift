import Combine

protocol UserConversationRepository {
    func getUserConversations() -> AnyPublisher<ConversationUser, ConversationError>
    
    func stopGettingUserConversations()
}
