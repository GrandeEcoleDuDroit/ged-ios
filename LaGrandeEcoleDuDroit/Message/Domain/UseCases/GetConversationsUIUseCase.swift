import Combine

class GetConversationsUiUseCase {
    private let conversationMessageRepository: ConversationMessageRepository
    
    init(conversationMessageRepository: ConversationMessageRepository) {
        self.conversationMessageRepository = conversationMessageRepository
    }
    
    func execute() -> AnyPublisher<[ConversationUi], Never> {
        conversationMessageRepository.conversationsMessage
            .map { conversationMessages in
                conversationMessages.map {
                    $0.toConversationUi()
                }
            }
            .eraseToAnyPublisher()
    }
}
