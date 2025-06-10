import Combine
import Foundation

class ListenRemoteConversationsUseCase {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private var cancellables = Set<AnyCancellable>()
    private var fetchedConversations: [String: Conversation] = [:]
    private let tag = String(describing: ListenRemoteConversationsUseCase.self)

    init(
        userRepository: UserRepository,
        conversationRepository: ConversationRepository
    ) {
        self.userRepository = userRepository
        self.conversationRepository = conversationRepository
    }
    
    func start() {
        userRepository.user
            .flatMap(conversationPublisher)
            .filter { self.fetchedConversations[$0.id] != $0 }
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] conversation in
                self?.fetchedConversations[conversation.id] = conversation
                Task { await self?.conversationRepository.upsertLocalConversation(conversation: conversation) }
            }.store(in: &cancellables)
                
    }
    
    func stop() {
        conversationRepository.stopListenConversations()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        fetchedConversations.removeAll()
    }
    
    private func conversationPublisher(_ user: User) -> AnyPublisher<Conversation, Never> {
        getLastConversationDate()
            .flatMap { offsetTime in
                self.listenRemoteConversations(userId: user.id, offsetTime: offsetTime)
            }
            .eraseToAnyPublisher()
    }
    
    private func getLastConversationDate() -> Future<Date?, Never> {
        Future<Date?, Never> { promise in
            Task {
                let offsetTime = await self.conversationRepository.getLastConversationDate()
                promise(.success(offsetTime))
            }
        }
    }
        
    private func listenRemoteConversations(userId: String,offsetTime: Date?) -> AnyPublisher<Conversation, Never> {
        conversationRepository
            .fetchRemoteConversations(userId: userId, offsetTime: offsetTime)
            .catch { error -> Empty<Conversation, Never> in
                e(self.tag, "Failed to fetch conversations: \(error)", error)
                return Empty(completeImmediately: true)
            }.eraseToAnyPublisher()
    }
}
