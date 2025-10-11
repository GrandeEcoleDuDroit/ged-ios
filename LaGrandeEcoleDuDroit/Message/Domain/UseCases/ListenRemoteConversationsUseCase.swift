import Combine
import Foundation

class ListenRemoteConversationsUseCase {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private let listenRemoteMessagesUseCase: ListenRemoteMessagesUseCase
    
    private var cancellables = Set<AnyCancellable>()
    private let tag = String(describing: ListenRemoteConversationsUseCase.self)

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
                    .fetchRemoteConversation(userId: user.id)
                    .catch { error -> Empty<Conversation, Never> in
                        e(self.tag, "Failed to fetch conversations: \(error)", error)
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
