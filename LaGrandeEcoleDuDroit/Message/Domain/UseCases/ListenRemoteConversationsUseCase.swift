import Combine
import Foundation

class ListenRemoteConversationsUseCase {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private var cancellables = Set<AnyCancellable>()
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
            .flatMap { user in
                self.stop()
                return self.conversationRepository
                    .fetchRemoteConversations(userId: user.id)
                    .catch { error -> Empty<Conversation, Never> in
                        e(self.tag, "Failed to fetch conversations: \(error)", error)
                        return Empty(completeImmediately: true)
                    }.eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] conversation in
                Task { await self?.conversationRepository.upsertLocalConversation(conversation: conversation) }
            }.store(in: &cancellables)
                
    }
    
    func stop() {
        conversationRepository.stopListenConversations()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
