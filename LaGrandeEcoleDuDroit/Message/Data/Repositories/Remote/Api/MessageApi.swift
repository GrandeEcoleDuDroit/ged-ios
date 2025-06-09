import Combine
import FirebaseCore
import Foundation

protocol MessageApi {
    func listenMessages(conversation: Conversation, offsetTime: Timestamp?) -> AnyPublisher<RemoteMessage, Error>
        
    func createMessage(conversationId: String, messageId: String, data: [String: Any]) async throws
    
    func updateSeenMessage(remoteMessage: RemoteMessage) async throws
    
    func stopListeningMessages()
}
