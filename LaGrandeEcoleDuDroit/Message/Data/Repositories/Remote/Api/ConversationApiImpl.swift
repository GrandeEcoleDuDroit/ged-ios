import Combine
import FirebaseFirestore
import os

let conversationTableName = "conversations"
private let tag = String(describing: ConversationApiImpl.self)

class ConversationApiImpl: ConversationApi {
    private var listeners: [ListenerRegistration] = []
    private let conversationCollection: CollectionReference = Firestore.firestore().collection(conversationTableName)
    private var cancellables: Set<AnyCancellable> = []
    
    func listenConversations(userId: String) -> AnyPublisher<RemoteConversation, Error> {
        let subject = PassthroughSubject<RemoteConversation, Error>()
        
        let listener = conversationCollection
            .whereField(ConversationDataFields.participants, arrayContains: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    e(tag, "Error to listen conversations: \(error.localizedDescription)")
                    subject.send(completion: .failure(error))
                    return
                }
                
                guard let snapshot = snapshot else {
                    e(tag, "Error to listen conversations: querySnapshot is nil")
                    return
                }
                
                snapshot.documentChanges.forEach { documentChanges in
                    switch documentChanges.type {
                        case .added, .modified:
                            if let remoteConversation = try? documentChanges.document.data(as: RemoteConversation.self) {
                                subject.send(remoteConversation)
                            } else {
                                e(tag, "Error to convert remote conversation")
                            }
                        case .removed:
                            break
                    }
                }
            }
        
        listeners.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    func createConversation(remoteConversation: RemoteConversation) async throws {
        do {
            try conversationCollection
                .document(remoteConversation.conversationId)
                .setData(from: remoteConversation)
        } catch {
            e(tag, "Error to create conversation: \(error.localizedDescription)")
            throw ConversationError.createFailed
        }
    }
    
    func deleteConversation(conversationId: String) async throws {
        do {
            try await conversationCollection
                .document(conversationId)
                .delete()
            
            let messagesSnapshot = try await conversationCollection
                .document(conversationId)
                .collection(messageTableName)
                .getDocuments()
            
            for document in messagesSnapshot.documents {
                try await document.reference.delete()
            }
        } catch {
            e(tag, "Error to delete conversation: \(error.localizedDescription)")
            throw ConversationError.deleteFailed
        }
    }
    
    func stopListeningConversations() {
        listeners.removeAll()
    }
}
