import Combine
import FirebaseCore
import Foundation

class ConversationRemoteDataSource {
    private let conversationApi: ConversationApi
    
    init(conversationApi: ConversationApi) {
        self.conversationApi = conversationApi
    }
    
    func listenConversations(userId: String, offsetTime: Date?) -> AnyPublisher<RemoteConversation, Error> {
        let offsetTime: Timestamp? = offsetTime.map { Timestamp(date: $0) }
        return conversationApi.listenConversations(userId: userId, offsetTime: offsetTime)
    }
    
    func createConversation(conversation: Conversation, userId: String) async throws {
        let data = conversation.toRemote(userId: userId).toMap()
        try await conversationApi.createConversation(conversationId: conversation.id, data: data)
    }
    
    func updateConversationDeleteTime(conversationId: String, userId: String, deleteTime: Date) async throws {
        let data = ["\(ConversationField.deleteTime).\(userId)": Timestamp(date: deleteTime)]
        try await conversationApi.updateConversation(conversationId: conversationId, data: data)
    }
    
    func stopListeningConversations() {
        conversationApi.stopListeningConversations()
    }
}
