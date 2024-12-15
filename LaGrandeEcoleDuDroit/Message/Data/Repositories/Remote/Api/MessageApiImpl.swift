import Combine
import Foundation
import FirebaseFirestore
import os

class MessageApiImpl: MessageApi {
    private let tag = String(describing: MessageApiImpl.self)
    private var listeners: [ListenerRegistration] = []
    private let conversationCollection: CollectionReference = Firestore.firestore().collection("conversations")
    
    func listenMessages(conversationId: String) -> AnyPublisher<[RemoteMessage], any Error> {
        let subject = CurrentValueSubject<[RemoteMessage], Error>([])
        
        let listener = conversationCollection
            .document(conversationId)
            .collection("messages")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    e(self.tag, "MessageApiImpl: Query error : \(error)")
                    return
                }
                
                guard let snapshot = snapshot else {
                    e(self.tag, "MessageApiImpl: No snapshot for messages")
                    return
                }
                
                let remoteMessages = snapshot.documents.compactMap { document in
                    try? document.data(as: RemoteMessage.self)
                }
                
                subject.send(remoteMessages)
            }
        
        listeners.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    func listenLastMessage(conversationId: String) -> AnyPublisher<RemoteMessage?, any Error> {
        let subject = CurrentValueSubject<RemoteMessage?, any Error>(nil)
        
        let listener = conversationCollection
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }

                if let error = error {
                    e(self.tag, "MessageApiImpl: Query error : \(error)")
                    return
                }
                
                guard let querySnapshot = querySnapshot else {
                    e(self.tag, "MessageApiImpl: No snapshot for last message")
                    return
                }
                
                let remoteMessage = querySnapshot.documents.compactMap { document in
                    try? document.data(as: RemoteMessage.self)
                }.first
                
                subject.send(remoteMessage)
            }
        
        listeners.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    func stopListeningLastMessages() {
        listeners.forEach { $0.remove() }
    }
}
