import Testing
import Foundation
import Combine

@testable import GrandeEcoleDuDroit

class DeleteConversationUseCaseTest {
    @Test
    func deleteConversationUseCase_should_delete_conversation() async {
        // Given
        let conversation = conversationFixture
        let testConversationRepository = TestConversationRepository()
        let useCase = DeleteConversationUseCase(
            conversationRepository: testConversationRepository,
            messageRepository: MockMessageRepository(),
            conversationMessageRepository: MockConversationMessageRepository()
        )
        
        // When
        try? await useCase.execute(conversation: conversation, userId: userFixture.id)
        
        // Then
        #expect(testConversationRepository.isConversationDeleted)
    }
    
    @Test
    func deleteConversationUseCase_should_delete_local_messages() async {
        // Given
        let conversation = conversationFixture
        let testMessageRepository = TestMessageRepository()
        let useCase = DeleteConversationUseCase(
            conversationRepository: MockConversationRepository(),
            messageRepository: testMessageRepository,
            conversationMessageRepository: MockConversationMessageRepository()
        )
        
        // When
        try? await useCase.execute(conversation: conversation, userId: userFixture.id)
        
        // Then
        #expect(testMessageRepository.isMessagesDeleted)
    }
}

private class TestConversationRepository: MockConversationRepository {
    var isConversationDeleted = false
    
    override func deleteConversation(conversationId: String, userId: String, date: Date) async throws {
        isConversationDeleted = true
    }
}

private class TestMessageRepository: MockMessageRepository {
    var isMessagesDeleted = false
    
    override func deleteLocalMessages(conversationId: String) async throws {
        isMessagesDeleted = true
    }
}
