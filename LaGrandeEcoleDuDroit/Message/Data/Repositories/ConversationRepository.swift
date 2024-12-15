import Combine

protocol ConversationRepository {
    func getConversations(userId: String) -> AnyPublisher<Conversation, Error>
    
    func stopGettingConversations()
}
