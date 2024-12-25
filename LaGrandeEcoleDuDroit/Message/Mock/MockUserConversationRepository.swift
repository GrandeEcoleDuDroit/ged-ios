import Foundation
import Combine

class MockUserConversationRepository: UserConversationRepository {
    func getUserConversations() -> AnyPublisher<ConversationUser, ConversationError> {
        Publishers.MergeMany(
            conversationsUserFixture.map {
                Just($0)
                    .setFailureType(to: ConversationError.self)
                    .eraseToAnyPublisher()
            }
        ).eraseToAnyPublisher()
    }
    
    func createConversation(conversationUser: ConversationUser) async throws {
        conversationsUserFixture.append(conversationUser)
    }
    
    func stopGettingUserConversations() {
        // No implementation needed
    }
}
