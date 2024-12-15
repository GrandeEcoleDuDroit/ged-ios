import Foundation
import Combine

class MockUserConversationRepository: UserConversationRepository {
    func getUserConversations() -> AnyPublisher<ConversationUser, any Error> {
        Publishers.MergeMany(
            conversationsUserFixture.map {
                Just($0)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        ).eraseToAnyPublisher()
    }
    
    func stopGettingUserConversations() {
        // No implementation needed
    }
}
