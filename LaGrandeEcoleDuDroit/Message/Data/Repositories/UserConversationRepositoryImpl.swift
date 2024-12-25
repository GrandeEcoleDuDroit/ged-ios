import Combine

class UserConversationRepositoryImpl: UserConversationRepository {
    private let tag = String(describing: UserConversationRepositoryImpl.self)
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(
        userRepository: UserRepository,
        conversationRepository: ConversationRepository
    ) {
        self.userRepository = userRepository
        self.conversationRepository = conversationRepository
        listenRemoteConversations()
    }
    
    func getUserConversations() -> AnyPublisher<ConversationUser, ConversationError> {
        conversationRepository.getConversationsFromLocal()
            .map { conversation, interlocutor in
                ConversationMapper.toConversationUser(conversation: conversation, interlocutor: interlocutor)
            }.eraseToAnyPublisher()
    }
    
    func createConversation(conversationUser: ConversationUser) async throws {
        let conversation = ConversationMapper.toConversation(conversationUser: conversationUser)
        guard let currentUser = userRepository.currentUser else {
            throw UserError.currentUserNotFound
        }
        
        try await conversationRepository.createConversation(
            conversation: conversation,
            interlocutor: conversationUser.interlocutor,
            currentUser: currentUser
        )
    }
    
    func deleteConversation(conversationId: String) async throws {
        try await conversationRepository.deleteConversation(conversationId: conversationId)
    }
    
    func stopGettingUserConversations() {
        conversationRepository.stopGettingConversations()
        cancellables.removeAll()
    }
    
    private func listenRemoteConversations() {
        guard let userId = userRepository.currentUser?.id else {
            return
        }
        
        conversationRepository.getConversationsFromRemote(userId: userId)
            .flatMap { [weak self] conversation in
                guard let self = self else {
                    return Empty<(Conversation, User), Never>(completeImmediately: true)
                        .eraseToAnyPublisher()
                }
                
                return self.userRepository.getUserPublisher(userId: conversation.interlocutorId)
                    .map { interlocutor in (conversation, interlocutor) }
                    .eraseToAnyPublisher()
            }
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                
                switch completion {
                case .finished:
                    d(self.tag, "UserConversationRepositoryImpl: listenRemoteConversations finished")
                    
                case .failure(let error):
                    e(self.tag, "UserConversationRepositoryImpl: listenRemoteConversations error: \(error)")
                }
            }, receiveValue: { [weak self] (conversation, interlocutor) in
                guard let self = self else { return }
                do {
                    try self.conversationRepository.upsertLocalConversation(
                        conversation: conversation,
                        interlocutor: interlocutor
                    )
                } catch {
                    e(self.tag, "UserConversationRepositoryImpl: listenRemoteConversations error: \(error)")
                }
            }).store(in: &cancellables)
    }
}
