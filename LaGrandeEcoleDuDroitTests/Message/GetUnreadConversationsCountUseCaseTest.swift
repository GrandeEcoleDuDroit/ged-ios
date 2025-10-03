import Testing
import Combine

@testable import GrandeEcoleDuDroit

class GetUnreadConversationsCountUseCaseTest {
    @Test
    func getUnreadConversationsCountUseCase_should_return_amount_of_conversation_with_unread_last_message() async {
        // Given
        let useCase = GetUnreadConversationsCountUseCase(
            conversationMessageRepository: AllUnreadConversations(),
            userRepository: CurrentUser()
        )
        let expectedCount = conversationMessagesFixture.count
        
        // When
        var iterator = useCase.execute().values.makeAsyncIterator()
        let result = await iterator.next()
        
        // Then
        #expect(result == expectedCount)
    }
}

private class CurrentUser: MockUserRepository {
    override var user: AnyPublisher<User, Never> {
        Just(userFixture).eraseToAnyPublisher()
    }
}

private class AllUnreadConversations: MockConversationMessageRepository {
    override var conversationsMessage: AnyPublisher<[String : ConversationMessage], Never> {
        let unreadConversationMessages = conversationMessagesFixture.map { conversationMessage in
            conversationMessage.with {
                $0.lastMessage = messageFixture.copy { $0.senderId = userFixture2.id; $0.seen = false }
            }
        }.reduce(into: [String: ConversationMessage]()) { result, conversationMessage in
            result[conversationMessage.conversation.id] = conversationMessage
        }
        
        return Just(unreadConversationMessages)
            .eraseToAnyPublisher()
    }
}
