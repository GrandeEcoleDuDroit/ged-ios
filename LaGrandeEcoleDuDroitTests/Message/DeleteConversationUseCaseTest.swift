import Testing
import Foundation
import Combine

@testable import GrandeEcoleDuDroit

class DeleteConversationUseCaseTest {
    @Test
    func deleteConversationUseCase_should_update_remote_conversation_delete_time() async {
        // Given
        let conversationRepository = UpdatedRemoteConversationDeleteTime()
        let useCase = DeleteConversationUseCase(
            conversationRepository: conversationRepository,
            messageRepository: MockMessageRepository(),
            conversationMessageRepository: MockConversationMessageRepository()
        )
        let conversation = conversationFixture.copy { $0.deleteTime = Date() }
        
        // When
        try? await useCase.execute(conversation: conversation, userId: userFixture.id)
        var iterator = conversationRepository.conversationChanges.values.makeAsyncIterator()
        let change = await iterator.next()
        let deleteTime = change?.updated.last?.deleteTime
        
        
        // Then
        #expect(deleteTime != nil && deleteTime! > conversation.deleteTime!)
    }
}

private class UpdatedRemoteConversationDeleteTime: MockConversationRepository {
    private let conversationChangeSubject = CurrentValueSubject<CoreDataChange<Conversation>, Never>(
        CoreDataChange(inserted: [conversationFixture])
    )
    override var conversationChanges: AnyPublisher<CoreDataChange<Conversation>, Never> {
        conversationChangeSubject.eraseToAnyPublisher()
    }
    
    override func deleteConversation(conversation: Conversation, userId: String, deleteTime: Date) async throws {
        conversationChangeSubject.send(CoreDataChange(updated: [conversation]))
    }
}
