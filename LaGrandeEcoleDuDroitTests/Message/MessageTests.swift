import XCTest
import Combine
@testable import La_Grande_Ecole_Du_Droit

final class MessageTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!
    private var messageRepository: MessageRepository!

    private var getLastMessagesUseCase: GetLastMessagesUseCase!
    private var getMessagesUseCase: GetMessagesUseCase!
    private var sendMessageUseCase: SendMessageUseCase!
    
    override func setUp() {
        cancellables = []
        messageRepository = MessageInjection.shared.resolveWithMock().resolve(MessageRepository.self)!
        
        getLastMessagesUseCase = GetLastMessagesUseCase(messageRepository: messageRepository)
        getMessagesUseCase = GetMessagesUseCase(messageRepository: messageRepository)
        sendMessageUseCase = SendMessageUseCase(messageRepository: messageRepository)
    }
    
    func testSendMessage() async throws {
        // Given
        let expectation = XCTestExpectation(description: #function)
        let message = messageFixture.with(id: "0000", conversationId: conversationUIFixture.id, content: "Test message")
        var result: Message?
        
        // When
        try await sendMessageUseCase.execute(message: message)
        messageRepository.getMessages(conversationId: conversationUIFixture.id)
            .sink(
                receiveCompletion: {_ in
                    XCTFail("Expected to receive value")
                },
                receiveValue: {
                    result = $0
                    expectation.fulfill()
                }
            ).store(in: &cancellables)
        
        // Then
        await fulfillment(of: [expectation], timeout: 5)
        XCTAssertEqual(result?.state, .sent)
        XCTAssertEqual(result, message)
    }
    
    func testGetLastMessage() async throws {
        // Given
        let expectation = XCTestExpectation(description: #function)
        var result: Message?
        let expectedMessage = messageFixture.with(id: "0000", conversationId: conversationUIFixture.id, content: "Test message")
        
        // When
        try await sendMessageUseCase.execute(message: expectedMessage)
        getLastMessagesUseCase.execute(conversationId: conversationUserFixture.id)
            .sink(
                receiveCompletion: {_ in
                    XCTFail("Expected to receive value")
                },
                receiveValue: {
                    result = $0
                    expectation.fulfill()
                }
            ).store(in: &cancellables)
        
        // Then
        await fulfillment(of: [expectation], timeout: 5)
        XCTAssertEqual(result, expectedMessage)
                
    }
    
    func testGetMessages() async throws {
        // Given
        let expectation = XCTestExpectation(description: #function)
        var result: [Message] = []
        
        // When
        getMessagesUseCase.execute(conversationId: conversationUserFixture.id)
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
        XCTAssertEqual(result, messagesFixture)
    }
}
