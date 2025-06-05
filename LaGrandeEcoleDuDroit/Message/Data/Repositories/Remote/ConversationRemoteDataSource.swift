import Combine
import FirebaseCore
import Foundation

class ConversationRemoteDataSource {
    private let conversationApi: ConversationApi
    
    init(conversationApi: ConversationApi) {
        self.conversationApi = conversationApi
    }
    
    func listenConversations(userId: String) -> AnyPublisher<RemoteConversation, Error> {
        conversationApi.listenConversations(userId: userId)
    }
    
    func createConversation(conversation: Conversation, userId: String) async throws {
        let data = conversation.toRemote(userId: userId).toMap()
        try await conversationApi.createConversation(conversationId: conversation.id, data: data)
    }
    
    func updateConversationDeleteTime(conversationId: String, userId: String, deleteTime: Date) async throws {
        let data = ["\(ConversationField.deleteTime.rawValue).\(userId)": Timestamp(date: deleteTime)]
        try await conversationApi.updateConversation(conversationId: conversationId, data: data)
    }
    
    func stopListeningConversations() {
        conversationApi.stopListeningConversations()
    }
}
