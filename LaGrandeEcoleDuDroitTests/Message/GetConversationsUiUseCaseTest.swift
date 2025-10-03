import Testing
import Combine

@testable import GrandeEcoleDuDroit

class GetConversationsUiUseCaseTest {
    @Test
    func getConversationsUiUseCase_should_return_conversationsUi() async {
        // Given
        let useCase = GetConversationsUiUseCase(conversationMessageRepository: AllConversationMessages())
        let expected = conversationMessagesFixture.map { $0.toConversationUi() }
        
        // When
        var iterator = useCase.execute().values.makeAsyncIterator()
        let result = await iterator.next()
        
        // Then
        #expect(result == expected)
    }
}

private class AllConversationMessages : MockConversationMessageRepository {
    override var conversationsMessage: AnyPublisher<[String : ConversationMessage], Never> {
        Just(conversationMessagesFixture.reduce(into: [:]) { result, message in
            result[message.conversation.id] = message
        }).eraseToAnyPublisher()
    }
}
