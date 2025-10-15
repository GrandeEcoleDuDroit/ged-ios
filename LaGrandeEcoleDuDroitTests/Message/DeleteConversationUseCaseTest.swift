import Testing
import Foundation
import Combine

@testable import GrandeEcoleDuDroit

class DeleteConversationUseCaseTest {
    @Test
    func deleteConversationUseCase_should_update_remote_conversation_delete_time() async {
        // Given
        let conversation = conversationFixture
        let conversationRepository = ConversationDeleteTimeUpdated(
            givenConversation: conversation.copy { $0.deleteTime = Date().addingTimeInterval(-1000) }
        )
        let useCase = DeleteConversationUseCase(
            conversationRepository: conversationRepository,
            messageRepository: MockMessageRepository(),
            conversationMessageRepository: MockConversationMessageRepository()
        )
        
        // When
        try? await useCase.execute(conversation: conversation, userId: userFixture.id)
        
        // Then
        #expect(conversationRepository.deleteTimeUpdated)
    }
}

private class ConversationDeleteTimeUpdated: MockConversationRepository {
    var deleteTimeUpdated: Bool = false
    let givenConversation: Conversation
    
    init(givenConversation: Conversation) {
        self.givenConversation = givenConversation
    }
    
    override func deleteConversation(conversation: Conversation, userId: String, deleteTime: Date) async throws {
        deleteTimeUpdated = conversation.deleteTime != nil && conversation.deleteTime! > givenConversation.deleteTime!
    }
}
