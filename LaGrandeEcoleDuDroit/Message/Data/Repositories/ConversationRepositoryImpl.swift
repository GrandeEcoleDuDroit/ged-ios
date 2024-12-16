import Combine

class ConversationRepositoryImpl: ConversationRepository {
    private let conversationLocalDataSource: ConversationLocalDataSource
    private let conversationRemoteDataSource: ConversationRemoteDataSource
    
    init(
        conversationLocalDataSource: ConversationLocalDataSource,
        conversationRemoteDataSource: ConversationRemoteDataSource
    ) {
        self.conversationLocalDataSource = conversationLocalDataSource
        self.conversationRemoteDataSource = conversationRemoteDataSource
    }
    
    func getConversationsFromRemote(userId: String) -> AnyPublisher<Conversation, Error> {
        conversationRemoteDataSource.listenConversations(userId: userId)
            .compactMap { ConversationMapper.toConversation(remoteConversation: $0, currrentUserId: userId) }
            .eraseToAnyPublisher()
    }
    
    func getConversationsFromLocal() -> AnyPublisher<(Conversation, User), ConversationError> {
        conversationLocalDataSource.conversationSubject
            .compactMap { ConversationMapper.toConversationWithInterlocutor(localConversation: $0) }
            .eraseToAnyPublisher()
    }
    
    func upsertLocalConversation(conversation: Conversation, interlocutor: User) {
        conversationLocalDataSource.upsertConversation(conversation: conversation, interlocutor: interlocutor)
    }
    
    func stopGettingConversations() {
        conversationRemoteDataSource.stopListeningConversations()
        conversationLocalDataSource.stopListeningConversations()
    }
}
