import Foundation
import Combine

class MockUserConversationRepository: UserConversationRepository {
    private let conversationsUser = CurrentValueSubject<[ConversationUser], Never>(conversationsUserFixture)
    
    func getUserConversations() -> AnyPublisher<ConversationUser, ConversationError> {
        conversationsUser
            .flatMap { conversations in
                Publishers.Sequence(sequence: conversations)
                    .setFailureType(to: ConversationError.self)
                    .eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
    
    func createConversation(conversationUser: ConversationUser) async throws {
        conversationsUser.value.append(conversationUser)
    }
    
    func updateConversation(conversationUser: ConversationUser) async throws {
        let index = conversationsUser.value.firstIndex { $0.id == conversationUser.id }!
        conversationsUser.value[index] = conversationUser
    }
    
    func deleteConversation(conversationId: String) async throws {
        conversationsUser.value.removeAll { $0.id == conversationId }
    }
    
    func stopGettingUserConversations() {
        // No implementation needed
    }
}
