import Combine
import FirebaseCore
import Foundation

protocol MessageApi {
    func listenMessages(userId: String, conversation: Conversation, offsetTime: Timestamp?) -> AnyPublisher<RemoteMessage, Error>
        
    func createMessage(remoteMessage: RemoteMessage) async throws
    
    func setMessageSeen(conversationId: String, messageId: String) async throws
    
    func updateMessageVisibility(remoteMessage: RemoteMessage, userId: String, visible: Bool) async throws

    func stopListeningMessages()
    
    func reportMessage(report: MessageReport) async throws    
}
