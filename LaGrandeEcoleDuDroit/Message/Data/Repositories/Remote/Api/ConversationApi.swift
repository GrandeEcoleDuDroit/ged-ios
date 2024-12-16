import Combine

protocol ConversationApi {
    func listenConversations(userId: String) -> AnyPublisher<RemoteConversation, Error>
    
    func stopListeningConversations()
}
