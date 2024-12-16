import FirebaseFirestore
import Combine

class UserFirestoreApiImpl: UserFirestoreApi {
    private let usersCollection: CollectionReference = Firestore.firestore().collection("users")
    private let tag = String(describing: UserFirestoreApiImpl.self)
    private var listeners: [ListenerRegistration] = []
    
    func createUser(firestoreUser: FirestoreUser) async throws {
        let userData = try Firestore.Encoder().encode(firestoreUser)
        let userRef = usersCollection.document(firestoreUser.userId)
        try await userRef.setData(userData)
    }
    
    func getUser(userId: String) async -> FirestoreUser? {
        let snapshot = try? await usersCollection.document(userId).getDocument()
        guard let snapshot = snapshot else {
            return nil
        }
        
        return try? snapshot.data(as: FirestoreUser.self)
    }
    
    func listenUser(userId: String) -> AnyPublisher<FirestoreUser?, Never> {
        let subject = CurrentValueSubject<FirestoreUser?, Never>(nil)
        
        let listener = usersCollection
            .document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    e(self.tag, "UserFirestoreApiImpl: Query error : \(error)")
                    subject.send(nil)
                    return
                }
                
                guard let snapshot = snapshot else {
                    e(self.tag, "UserFirestoreApiImpl: No snapshot for user: \(userId)")
                    subject.send(nil)
                    return
                }
                
                if let user = try? snapshot.data(as: FirestoreUser.self) {
                    subject.send(user)
                } else {
                    subject.send(nil)
                }
            }
        listeners.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    func getUsers() async throws -> [FirestoreUser] {
        let snapshot = try await usersCollection.getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: FirestoreUser.self) }
    }
    
    func stopListeningUsers() {
        listeners.removeAll()
    }
}
