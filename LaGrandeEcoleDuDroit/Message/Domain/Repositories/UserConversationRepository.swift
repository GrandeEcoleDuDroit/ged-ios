import Combine

protocol UserConversationRepository {
    func getUserConversations() -> AnyPublisher<ConversationUser, Error>
    
    func stopGettingUserConversations()
}
