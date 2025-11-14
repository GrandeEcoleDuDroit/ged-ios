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
        try await mapFirebaseException(
            block: {
                let data = conversation.toRemote(userId: userId).toMap()
                try await conversationApi.createConversation(conversationId: conversation.id, data: data)
            },
            tag: tag,
            message: "Failed to create conversation"
        )
    }
    
    func updateConversationDeleteTime(conversationId: String, userId: String, deleteTime: Date) async throws {
        try await mapFirebaseException(
            block: {
                let data = ["\(ConversationField.Remote.deleteTime).\(userId)": Timestamp(date: deleteTime)]
                try await conversationApi.updateConversation(conversationId: conversationId, data: data)
            }
        )
    }
    
    func stopListeningConversations() {
        conversationApi.stopListeningConversations()
    }
}
