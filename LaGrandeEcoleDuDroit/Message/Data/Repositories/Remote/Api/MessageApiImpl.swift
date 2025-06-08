import Combine
import Foundation
import FirebaseFirestore
import os

let messageTableName = "messages"
private let tag = String(describing: MessageApiImpl.self)

class MessageApiImpl: MessageApi {
    private var messageListeners: [ListenerRegistration] = []
    private let conversationCollection: CollectionReference = Firestore.firestore().collection(conversationTableName)
    
    func listenMessages(conversationId: String, offsetTime: Timestamp?) -> AnyPublisher<RemoteMessage, Error> {
        let subject = PassthroughSubject<RemoteMessage, Error>()
        
        let listener = conversationCollection
            .document(conversationId.description)
            .collection(messageTableName)
            .withOffsetTime(offsetTime)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                snapshot?.documents
                    .compactMap({ try? $0.data(as: RemoteMessage.self) })
                    .forEach {
                        subject.send($0)
                    }
            }
        
        messageListeners.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    func createMessage(conversationId: String, messageId: String, data: [String: Any]) async throws {
        try await conversationCollection
            .document(conversationId)
            .collection(messageTableName)
            .document(messageId)
            .setData(data, merge: true)
    }
    
    func updateSeenMessage(remoteMessage: RemoteMessage) throws {
        conversationCollection
            .document(remoteMessage.conversationId)
            .collection(messageTableName)
            .document(remoteMessage.messageId.toString())
            .updateData([MessageField.seen: remoteMessage.seen]) { completion in
                completion.map { error in
                    e("MessageApiImpl", error.localizedDescription)
                }
            }
    }
    
    func stopListeningMessages() {
        messageListeners.forEach { $0.remove() }
    }
}
