import Combine
import Foundation
import FirebaseFirestore
import os

let messageTableName = "messages"
private let tag = String(describing: MessageApiImpl.self)

class MessageApiImpl: MessageApi {
    private var lastMessageListeners: [ListenerRegistration] = []
    private var messageListeners: [ListenerRegistration] = []
    private let conversationCollection: CollectionReference = Firestore.firestore().collection(conversationTableName)
    
    func listenMessages(conversationId: String) -> AnyPublisher<RemoteMessage, any Error> {
        let subject = PassthroughSubject<RemoteMessage, Error>()
        
        let listener = conversationCollection
            .document(conversationId)
            .collection(messageTableName)
            .order(by: MessageDataFields.timestamp, descending: true)
            .limit(to: 10)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    e(tag, "MessageApiImpl: Query error : \(error)")
                    return
                }
                
                guard let snapshot = snapshot else {
                    e(tag, "MessageApiImpl: No snapshot for messages")
                    return
                }
                
                snapshot.documentChanges.forEach { documentChanges in
                    if let remoteMessage = try? documentChanges.document.data(as: RemoteMessage.self) {
                        subject.send(remoteMessage)
                    } else {
                        e(tag, "Error to convert remote message")
                    }
                }
            }
        
        messageListeners.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    func listenLastMessage(conversationId: String) -> AnyPublisher<RemoteMessage?, ConversationError> {
        let subject = CurrentValueSubject<RemoteMessage?, ConversationError>(nil)
        
        let listener = conversationCollection
            .document(conversationId)
            .collection(messageTableName)
            .order(by: MessageDataFields.timestamp, descending: true)
            .limit(to: 1)
            .addSnapshotListener { querySnapshot, error in                
                if let error = error {
                    e(tag, "MessageApiImpl: Query error : \(error)")
                    return
                }
                
                guard let querySnapshot = querySnapshot else {
                    e(tag, "MessageApiImpl: No snapshot for last message")
                    return
                }
                
                querySnapshot.documentChanges.forEach { documentChanges in
                    if let remoteMessage = try? documentChanges.document.data(as: RemoteMessage.self) {
                        subject.send(remoteMessage)
                    } else {
                        e(tag, "Error to convert remote message")
                    }
                }
            }
        
        lastMessageListeners.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    func createMessage(remoteMessage: RemoteMessage) async throws {
        do {
            try conversationCollection
                .document(remoteMessage.conversationId)
                .collection(messageTableName)
                .document(remoteMessage.messageId)
                .setData(from: remoteMessage)
        } catch {
            e(tag, "MessageApiImpl: Error creating message: \(error)")
            throw MessageError.createMessageError
        }
    }
    
    func stopListeningMessages() {
        messageListeners.forEach { $0.remove() }
    }
    
    func stopListeningLastMessages() {
        lastMessageListeners.forEach { $0.remove() }
    }
}
