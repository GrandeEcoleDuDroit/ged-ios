import Combine
import FirebaseCore
import Foundation

protocol MessageApi {
    func listenMessages(conversationId: String, offsetTime: Timestamp?) -> AnyPublisher<RemoteMessage, Error>
        
    func createMessage(remoteMessage: RemoteMessage) async throws
    
    func updateSeenMessage(remoteMessage: RemoteMessage) async throws
    
    func stopListeningMessages()
}
