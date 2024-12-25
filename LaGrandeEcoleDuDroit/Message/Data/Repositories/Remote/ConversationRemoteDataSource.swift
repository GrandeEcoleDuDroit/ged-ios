import Combine

class ConversationRemoteDataSource {
    private let conversationApi: ConversationApi
    
    init(conversationApi: ConversationApi) {
        self.conversationApi = conversationApi
    }
    
    func listenConversations(userId: String) -> AnyPublisher<RemoteConversation, Error> {
        conversationApi.listenConversations(userId: userId)
    }
    
    func createConversation(remoteConversation: RemoteConversation) async throws {
        try await conversationApi.createConversation(remoteConversation: remoteConversation)
    }
    
    func stopListeningConversations() {
        conversationApi.stopListeningConversations()
    }
}
