import Combine
import Foundation

private let tag = String(describing: ListenRemoteConversationUseCase.self)

class ListenRemoteConversationUseCase {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private var cancellables = Set<AnyCancellable>()
    private var fetchedConversations = Dictionary<String, Conversation>()
    
    init(
        userRepository: UserRepository,
        conversationRepository: ConversationRepository,
    ) {
        self.userRepository = userRepository
        self.conversationRepository = conversationRepository
    }
    
    func start() {
        userRepository.user
            .flatMap { user in
                self.getConversationOffsetTime()
                .flatMap { offsetTime in
                    self.getRemoteConversationsPublisher(userId: user.id, offsetTime: offsetTime)
                }
            }
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] conversation in
                if self?.fetchedConversations[conversation.id] != conversation {
                    self?.fetchedConversations[conversation.id] = conversation
                    Task { await self?.conversationRepository.upsertLocalConversation(conversation: conversation) }
                }
            }.store(in: &cancellables)
                
    }
    
    private func getConversationOffsetTime() -> Future<Date?, Never> {
        Future<Date?, Never> { promise in
            Task {
                let offsetTime = await self.conversationRepository.getLastConversationDate()
                promise(.success(offsetTime))
            }
        }
    }
        
    private func getRemoteConversationsPublisher(
        userId: String,
        offsetTime: Date?
    ) -> AnyPublisher<Conversation, Never> {
        conversationRepository
            .fetchRemoteConversations(userId: userId, offsetTime: offsetTime)
            .catch { error -> Empty<Conversation, Never> in
                e(tag, "Failed to fetch conversations: \(error)", error)
                return Empty(completeImmediately: true)
            }.eraseToAnyPublisher()
    }
    
    func stop() {
        conversationRepository.stopListenConversations()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        fetchedConversations.removeAll()
    }
}
