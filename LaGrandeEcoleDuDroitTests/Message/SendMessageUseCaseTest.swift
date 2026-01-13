import Testing

@testable import GrandeEcoleDuDroit

class SendMessageUseCaseTest {
    @Test
    func sendMessageUseCase_should_create_conversation_locally_when_state_is_draft() async throws {
        // Given
        let conversation = conversationFixture
        let localConversationCreated = LocalConversationCreated(conversation)
        
        let useCase = SendMessageUseCase(
            messageRepository: MockMessageRepository(),
            conversationRepository: localConversationCreated,
            sendMessageNotificationUseCase: MockSendMessageNotificationUseCase()
        )
        
        // When
        await useCase.execute(
            conversation: conversation.copy{ $0.state = .draft },
            message: messageFixture,
            userId: userFixture.id
        )
        
        // Then
        #expect(localConversationCreated.createLocalConversationCalled)
    }
    
    @Test
    func sendMessageUseCase_should_create_message_locally_when_state_is_draft() async throws {
        // Given
        let message = messageFixture
        let localMessageCreated = LocalMessageCreated(message)
        
        let useCase = SendMessageUseCase(
            messageRepository: localMessageCreated,
            conversationRepository: MockConversationRepository(),
            sendMessageNotificationUseCase: MockSendMessageNotificationUseCase()
        )
        
        // When
        await useCase.execute(
            conversation: conversationFixture,
            message: message.copy{ $0.state = .draft },
            userId: userFixture.id
        )
        
        // Then
        #expect(localMessageCreated.createLocalMessageCalled)
    }
    
    @Test
    func sendMessageUseCase_should_create_conversation_remotely_when_state_is_draft() async throws {
        // Given
        let conversation = conversationFixture
        let remoteConversationCreated = RemoteConversationCreated(conversation)
        
        let useCase = SendMessageUseCase(
            messageRepository: MockMessageRepository(),
            conversationRepository: remoteConversationCreated,
            sendMessageNotificationUseCase: MockSendMessageNotificationUseCase()
        )
        
        // When
        await useCase.execute(
            conversation: conversation.copy{ $0.state = .draft },
            message: messageFixture,
            userId: userFixture.id
        )
        
        // Then
        #expect(remoteConversationCreated.createRemoteConversationCalled)
    }
    
    @Test
    func sendMessageUseCase_should_send_message_notification() async throws {
        // Given
        let messageNotificationSent = TestSendMessageNotificationUseCase()
        
        let useCase = SendMessageUseCase(
            messageRepository: MockMessageRepository(),
            conversationRepository: MockConversationRepository(),
            sendMessageNotificationUseCase: messageNotificationSent
        )
        
        // When
        await useCase.execute(
            conversation: conversationFixture,
            message: messageFixture,
            userId: userFixture.id
        )
        
        // Then
        #expect(messageNotificationSent.sendMessageNotificationCalled)
    }
}

private class LocalConversationCreated: MockConversationRepository {
    private(set) var createLocalConversationCalled = false
    private let conversation: Conversation
    
    init(_ conversation: Conversation) {
        self.conversation = conversation
    }
    
    override func createLocalConversation(conversation: Conversation) async throws {
        createLocalConversationCalled = self.conversation.id == conversation.id
    }
}

private class LocalMessageCreated: MockMessageRepository {
    private(set) var createLocalMessageCalled = false
    private let message: Message
    
    init(_ message: Message) {
        self.message = message
    }
    
    override func createLocalMessage(message: Message) async throws {
        createLocalMessageCalled = self.message.id == message.id
    }
}

private class RemoteConversationCreated: MockConversationRepository {
    private(set) var createRemoteConversationCalled = false
    private let conversation: Conversation
    
    init(_ conversation: Conversation) {
        self.conversation = conversation
    }
    
    override func createRemoteConversation(conversation: Conversation, userId: String) async throws {
        createRemoteConversationCalled = self.conversation.id == conversation.id
    }
}

private class TestSendMessageNotificationUseCase: MockSendMessageNotificationUseCase {
    private(set) var sendMessageNotificationCalled = false
    
    override func execute(notification: MessageNotification) async {
        sendMessageNotificationCalled = true
    }
}
