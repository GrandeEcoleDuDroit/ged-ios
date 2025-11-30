import Combine
import Foundation

private let tag = String(describing: ListenRemoteConversationsUseCase.self)

class ListenRemoteConversationsUseCase {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private let listenRemoteMessagesUseCase: ListenRemoteMessagesUseCase
    
    private var cancellables = Set<AnyCancellable>()

    init(
        userRepository: UserRepository,
        conversationRepository: ConversationRepository,
        listenRemoteMessagesUseCase: ListenRemoteMessagesUseCase
    ) {
        self.userRepository = userRepository
        self.conversationRepository = conversationRepository
        self.listenRemoteMessagesUseCase = listenRemoteMessagesUseCase
    }
    
    func start() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        userRepository.user
            .map { user in
                self.conversationRepository
                    .fetchRemoteConversations(userId: user.id)
                    .catch { error -> Empty<Conversation, Never> in
                        e(tag, "Failed to fetch conversations", error)
                        return Empty()
                    }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] conversation in
                Task {
                    try? await self?.conversationRepository.upsertLocalConversation(conversation: conversation)
                }
                self?.listenRemoteMessagesUseCase.start(conversation: conversation)
            }.store(in: &cancellables)
                
    }
    
    func stop() {
        conversationRepository.stopListenConversations()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
