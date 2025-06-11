import Combine
import FirebaseFirestore
import os

let conversationTableName = "conversations"

class ConversationApiImpl: ConversationApi {
    private var listeners: [ListenerRegistration] = []
    private let conversationCollection: CollectionReference = Firestore.firestore().collection(conversationTableName)
    
    func listenConversations(userId: String, notInConversationIds: [String]) -> AnyPublisher<RemoteConversation, Error> {
        let subject = PassthroughSubject<RemoteConversation, Error>()
        
        let listener = conversationCollection
            .whereField(ConversationDataFields.participants, arrayContains: userId)
            .whereField(ConversationDataFields.conversationId, notIn: notInConversationIds)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                snapshot?.documents.forEach { document in
                    if let remoteConversation = try? document.data(as: RemoteConversation.self) {
                        subject.send(remoteConversation)
                    }
                }
            }
        
        listeners.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    func createConversation(conversationId: String, data: [String: Any]) async throws {
        try await conversationCollection
            .document(conversationId)
            .setData(data, merge: true)
    }
    
    func updateConversation(conversationId: String, data: [String: Any]) async throws {
        try await conversationCollection
            .document(conversationId)
            .updateData(data)
    }
    
    func stopListeningConversations() {
        listeners.forEach { $0.remove() }
    }
}
