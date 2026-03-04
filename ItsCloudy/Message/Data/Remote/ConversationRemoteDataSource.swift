import Combine
import FirebaseCore
import Foundation

class ConversationRemoteDataSource {
    private let tag = String(describing: ConversationRemoteDataSource.self)
    private let conversationApi: ConversationApi
    
    init(conversationApi: ConversationApi) {
        self.conversationApi = conversationApi
    }
    
    func listenConversations(userId: String) -> AnyPublisher<RemoteConversation, Error> {
        conversationApi.listenConversations(userId: userId)
    }
    
    func createConversation(conversation: Conversation, userId: String) async throws {
        do {
            try await conversationApi.createConversation(remoteConversation: conversation.toRemote(userId: userId))
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func updateConversationEffectiveFrom(conversationId: String, userId: String, date: Date) async throws {
        do {
            let data = ["\(ConversationField.Remote.effectiveFrom).\(userId)": Timestamp(date: date)]
            try await conversationApi.updateConversation(conversationId: conversationId, data: data)
        } catch {
            throw mapFirebaseError(error)
        }
    }
    
    func stopListeningConversations() {
        conversationApi.stopListeningConversations()
    }
}
