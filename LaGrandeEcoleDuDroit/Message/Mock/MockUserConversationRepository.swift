import Foundation
import Combine

class MockUserConversationRepository: UserConversationRepository {
    private var conversations: [ConversationUser] = conversationsUserFixture
    
    func getUserConversations() -> AnyPublisher<ConversationUser, ConversationError> {
        Publishers.MergeMany(
            conversations.map {
                Just($0)
                    .setFailureType(to: ConversationError.self)
                    .eraseToAnyPublisher()
            }
        ).eraseToAnyPublisher()
    }
    
    func createConversation(conversationUser: ConversationUser) async throws {
        conversationsUserFixture.append(conversationUser)
    }
    
    func deleteConversation(conversationId: String) async throws {
        // Cannot be implementated
    }
    
    func stopGettingUserConversations() {
        // No implementation needed
    }
}
