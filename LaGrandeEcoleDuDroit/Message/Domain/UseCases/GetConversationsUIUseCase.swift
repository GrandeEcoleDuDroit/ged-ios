import Combine

class GetConversationsUIUseCase {
    private let getConversationsUseCase: GetConversationsUseCase
    private let getLastMessagesUseCase: GetLastMessagesUseCase
    
    init(
        getConversationsUseCase: GetConversationsUseCase,
        getLastMessagesUseCase: GetLastMessagesUseCase
    ) {
        self.getConversationsUseCase = getConversationsUseCase
        self.getLastMessagesUseCase = getLastMessagesUseCase
    }
    
    func execute() -> AnyPublisher<ConversationUI, ConversationError> {
        getConversationsUseCase.execute()
            .map { conversation in
                ConversationUI(
                    id: conversation.id,
                    interlocutor: conversation.interlocutor,
                    lastMessage: nil
                )
            }
            .flatMap { [weak self] conversationUI in
                guard let self = self else {
                    return Empty<ConversationUI, ConversationError>().eraseToAnyPublisher()
                }
                
                return self.getLastMessagesUseCase.execute(conversationId: conversationUI.id)
                    .map { conversationUI.with(lastMessage: $0) }
                    .eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
    
    func stop() {
        getConversationsUseCase.stop()
        getLastMessagesUseCase.stop()
    }
}
