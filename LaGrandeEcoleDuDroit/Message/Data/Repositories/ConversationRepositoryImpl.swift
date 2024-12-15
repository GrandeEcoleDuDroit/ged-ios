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
    
    func getConversations(userId: String) -> AnyPublisher<Conversation, Error> {
        conversationRemoteDataSource.listenConversations(userId: userId)
            .map { remoteConversations in
                remoteConversations.compactMap {
                    ConversationMapper.toConversation(remoteConversation: $0, currrentUserId: userId)
                }
            }
            .flatMap { (conversation: [Conversation]) -> AnyPublisher<Conversation, Error> in
                Publishers.Sequence(sequence: conversation)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func stopGettingConversations() {
        conversationRemoteDataSource.stopListeningConversations()
    }
}
