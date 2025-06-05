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
                    .filter({ !$0.metadata.isFromCache })
                    .compactMap({ try? $0.data(as: RemoteMessage.self) })
                    .forEach {
                        subject.send($0)
                    }
            }
        
        messageListeners.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    func createMessage(remoteMessage: RemoteMessage) async throws {
        try await conversationCollection
            .document(remoteMessage.conversationId)
            .collection(messageTableName)
            .document(remoteMessage.messageId.toString())
            .updateData([MessageField.seen: remoteMessage.seen])
    }
    
    func updateSeenMessage(remoteMessage: RemoteMessage) async throws {
        try await conversationCollection
            .document(remoteMessage.conversationId)
            .collection(messageTableName)
            .document(remoteMessage.messageId.toString())
            .updateData([MessageDataFields.seen: remoteMessage.seen])
    }
    
    func stopListeningMessages() {
        messageListeners.forEach { $0.remove() }
    }
}

extension CollectionReference {
    func withOffsetTime(_ offsetTime: Timestamp?) -> Query {
        if let offsetTime = offsetTime {
            self.whereField(MessageField.timestamp.rawValue, isGreaterThan: offsetTime)
        } else {
            self
        }
    }
}

