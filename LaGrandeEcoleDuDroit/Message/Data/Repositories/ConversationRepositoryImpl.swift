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
    
    func upsertLocalConversation(conversation: Conversation, interlocutor: User) throws {
        try conversationLocalDataSource.upsertConversation(conversation: conversation, interlocutor: interlocutor)
    }
    
    func createConversation(
        conversation: Conversation,
        interlocutor: User,
        currentUser: User
    ) async throws {
        let remoteConversation = ConversationMapper.toRemote(
            conversation: conversation,
            currentUserId: currentUser.id
        )
        
        try conversationLocalDataSource.insertConversation(
            conversation: conversation,
            interlocutor: interlocutor
        )
        try await conversationRemoteDataSource.createConversation(remoteConversation: remoteConversation)
    }
    
    func stopGettingConversations() {
        conversationRemoteDataSource.stopListeningConversations()
        conversationLocalDataSource.stopListeningConversations()
    }
}
