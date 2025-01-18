import XCTest
import Combine
@testable import La_Grande_Ecole_Du_Droit

final class ConversationTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!
    private var userConversationRepository: UserConversationRepository!
    private var messageRepository: MessageRepository!

    private var createConversationUseCase: CreateConversationUseCase!
    private var deleteConversationUseCase: DeleteConversationUseCase!
    private var getConversationsUIUseCase: GetConversationsUIUseCase!
    private var getConversationsUserUseCase: GetConversationsUserUseCase!
    private var getLastMessagesUseCase: GetLastMessagesUseCase!
    
    override func setUp() {
        cancellables = []
        userConversationRepository = MessageInjection.shared.resolveWithMock().resolve(UserConversationRepository.self)
        messageRepository = MessageInjection.shared.resolveWithMock().resolve(MessageRepository.self)
        
        createConversationUseCase = CreateConversationUseCase(userConversationRepository: userConversationRepository)
        deleteConversationUseCase = DeleteConversationUseCase(userConversationRepository: userConversationRepository)
        getConversationsUserUseCase = GetConversationsUserUseCase(userConversationRepository: userConversationRepository)
        getLastMessagesUseCase = GetLastMessagesUseCase(messageRepository: messageRepository)
        getConversationsUIUseCase = GetConversationsUIUseCase(
            getConversationsUserUseCase: getConversationsUserUseCase,
            getLastMessagesUseCase: getLastMessagesUseCase
        )
    }
    
    func testGetConversationUI() async throws {
        // Given
        let expectation = XCTestExpectation(description: #function)
        var result: [ConversationUI] = []
        
        // When
        getConversationsUIUseCase.execute()
            .sink(
                receiveCompletion: {_ in
                    XCTFail("Expected to receive value")
                },
                receiveValue: {
                    result.append($0)
                    expectation.fulfill()
                }
            ).store(in: &cancellables)
        
        // Then
        await fulfillment(of: [expectation], timeout: 5)
        for (index, conversation) in result.enumerated() {
            XCTAssertEqual(conversation.id, conversationsUIFixture[index].id)
            XCTAssertEqual(conversation.lastMessage, conversationsUIFixture[index].lastMessage)
        }
    }
    
    func testGetConversationUser() async throws {
        // Given
        let expectation = XCTestExpectation(description: #function)
        var result: [ConversationUser] = []
        
        // When
        getConversationsUserUseCase.execute()
            .sink(
                receiveCompletion: {_ in
                    XCTFail("Expected to receive value")
                },
                receiveValue: {
                    result.append($0)
                    expectation.fulfill()
                }
            ).store(in: &cancellables)
        
        // Then
        await fulfillment(of: [expectation], timeout: 5)
        XCTAssertEqual(result, conversationsUserFixture)
    }
    
    func testCreateConversation() async throws {
        // Given
        let expectation = XCTestExpectation(description: #function)
        let conversationUI = conversationUIFixture.with(id: "0000")
        var result: [ConversationUser] = []
        
        // When
        try await createConversationUseCase.execute(conversationUI: conversationUI)
        userConversationRepository.getUserConversations()
            .sink(
                receiveCompletion: {_ in
                    XCTFail("Expected to receive value")
                },
                receiveValue: {
                    result.append($0)
                    expectation.fulfill()
                }
            ).store(in: &cancellables)
        
        // Then
        await fulfillment(of: [expectation], timeout: 5)
        XCTAssertTrue(result.contains(where: { $0.id == conversationUI.id }))
    }
    
    func testDeleteConversation() async throws {
        // Given
        let expectation = XCTestExpectation(description: #function)
        var result: [ConversationUser] = []
        
        // When
        try await deleteConversationUseCase.execute(conversationId: conversationUIFixture.id)
        userConversationRepository.getUserConversations()
            .sink(
                receiveCompletion: {_ in
                    XCTFail("Expected to receive value")
                },
                receiveValue: {
                    result.append($0)
                    expectation.fulfill()
                }
            ).store(in: &cancellables)
        
        // Then
        await fulfillment(of: [expectation], timeout: 5)
        XCTAssertFalse(result.contains(where: { $0.id == conversationUIFixture.id }))
    }
}

