import Combine

class UserConversationRepositoryImpl: UserConversationRepository {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    
    init(
        userRepository: UserRepository,
        conversationRepository: ConversationRepository
    ) {
        self.userRepository = userRepository
        self.conversationRepository = conversationRepository
    }
    
    func getUserConversations() -> AnyPublisher<ConversationUser, any Error> {
        guard let userId = userRepository.currentUser?.id else {
            return Fail(error: UserError.currentUserNotFound).eraseToAnyPublisher()
        }
        
        return conversationRepository.getConversations(userId: userId)
            .flatMap { conversation in
                Future<ConversationUser?, Error> { [weak self] promise in
                    Task {
                        if let interlocutor = await self?.userRepository.getUser(userId: conversation.interlocutorId) {
                            let conversationUser = ConversationMapper.toConversationUser(conversation: conversation, interlocutor: interlocutor)
                            promise(.success(conversationUser))
                        } else {
                            promise(.success(nil))
                        }
                    }
                }
                .compactMap { $0 }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func stopGettingUserConversations() {
        conversationRepository.stopGettingConversations()
    }
}
