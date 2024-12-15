import Combine
import FirebaseFirestore
import os

class ConversationApiImpl: ConversationApi {
    private let tag = String(describing: ConversationApiImpl.self)
    private var listeners: [ListenerRegistration] = []
    private let conversationCollection: CollectionReference = Firestore.firestore().collection("conversations")
    private var cancellables: Set<AnyCancellable> = []
    
    func listenConversations(userId: String) -> AnyPublisher<[RemoteConversation], Error> {
        let subject = PassthroughSubject<[RemoteConversation], Error>()
        
        let listener = conversationCollection
            .whereField("participants", arrayContains: userId)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    e(self.tag, "Error to listen conversations: \(error.localizedDescription)")
                    subject.send(completion: .failure(error))
                    return
                }
                
                guard let querySnapshot = querySnapshot else {
                    e(self.tag, "Error to listen conversations: querySnapshot is nil")
                    subject.send([])
                    return
                }
                
                let remoteConversations = querySnapshot.documents.compactMap { document -> RemoteConversation? in
                    try? document.data(as: RemoteConversation.self)
                }
                
                subject.send(remoteConversations)
            }
        
        listeners.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    func stopListeningConversations() {
        listeners.forEach { $0.remove() }
    }
}
