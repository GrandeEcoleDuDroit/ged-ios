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
    
    func execute() -> AnyPublisher<ConversationUI, Error> {
        getConversationsUseCase.execute()
            .map { conversation in
                ConversationUI(
                    id: conversation.id,
                    interlocutor: conversation.interlocutor,
                    lastMessage: nil
                )
            }
            .flatMap { conversationUI in
                self.getLastMessagesUseCase.execute(conversationId: conversationUI.id)
                    .map { lastMessage in
                        conversationUI.with(lastMessage: lastMessage)
                    }
            }.eraseToAnyPublisher()
    }
    
    func stop() {
        getConversationsUseCase.stop()
        getLastMessagesUseCase.stop()
    }
}
