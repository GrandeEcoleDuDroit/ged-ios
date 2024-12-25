import Combine

class GetConversationsUIUseCase {
    private let getConversationsUserUseCase: GetConversationsUserUseCase
    private let getLastMessagesUseCase: GetLastMessagesUseCase
    
    init(
        getConversationsUserUseCase: GetConversationsUserUseCase,
        getLastMessagesUseCase: GetLastMessagesUseCase
    ) {
        self.getConversationsUserUseCase = getConversationsUserUseCase
        self.getLastMessagesUseCase = getLastMessagesUseCase
    }
    
    func execute() -> AnyPublisher<ConversationUI, ConversationError> {
        getConversationsUserUseCase.execute()
            .map { ConversationMapper.toConversationUI(conversationUser: $0) }
            .flatMap { [weak self] conversationUI in
                guard let self = self else {
                    return Empty<ConversationUI, ConversationError>()
                        .eraseToAnyPublisher()
                }
                
                return self.getLastMessagesUseCase.execute(conversationId: conversationUI.id)
                    .map { conversationUI.with(lastMessage: $0) }
                    .eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
    
    func stop() {
        getConversationsUserUseCase.stop()
        getLastMessagesUseCase.stop()
    }
}
