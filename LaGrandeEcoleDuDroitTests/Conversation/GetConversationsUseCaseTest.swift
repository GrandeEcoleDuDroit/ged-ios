import Testing

@testable import GrandeEcoleDuDroit

class GetConversationUseCaseTest {
    @Test
    func getConversationUseCase_should_return_conversation_when_exist() async throws {
        // Given
        let useCase = GetConversationUseCase(
            userRepository: MockUserRepository(),
            conversationRepository: SingleConversation()
        )
        
        // When
        let result = try await useCase.execute(interlocutor: userFixture)
        
        // Then
        #expect(result == conversationFixture)
    }
    
    @Test
    func getConversationUseCase_should_return_new_conversation_when_not_exist() async throws {
        // Given
        let useCase = GetConversationUseCase(
            userRepository: CurrentUser(),
            conversationRepository: MockConversationRepository()
        )
        
        // When
        let result = try await useCase.execute(interlocutor: userFixture2)
        
        // Then
        #expect(result.state == .draft)
    }
    
    @Test
    func getConversationUseCase_should_throw_error_when_current_user_not_exist() async throws {
        // Given
        let useCase = GetConversationUseCase(
            userRepository: MockUserRepository(),
            conversationRepository: MockConversationRepository()
        )
        
        // When
        let error = await #expect(throws: UserError.currentUserNotFound.self) {
            try await useCase.execute(interlocutor: userFixture)
        }
        
        // Then
        #expect(error == UserError.currentUserNotFound)
    }
}

private class SingleConversation: MockConversationRepository {
    override func getConversation(interlocutorId: String) async throws -> Conversation? {
        conversationFixture
    }
}

private class CurrentUser: MockUserRepository {
    override var currentUser: User? {
        userFixture
    }
}
