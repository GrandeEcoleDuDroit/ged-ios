import FirebaseFirestore
import Combine

let userTableName = "users"

private let tag = String(describing: UserFirestoreApiImpl.self)

class UserFirestoreApiImpl: UserFirestoreApi {
    private let usersCollection: CollectionReference = Firestore.firestore().collection(userTableName)
    private var listeners: [ListenerRegistration] = []
    
    func listenCurrentUser(userId: String) -> AnyPublisher<FirestoreUser?, Error> {
        let subject = CurrentValueSubject<FirestoreUser?, Error>(nil)
        
        let listener = usersCollection
            .document(userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                guard let snapshot = snapshot else { return }
                
                if let user = try? snapshot.data(as: FirestoreUser.self) {
                    subject.send(user)
                } else {
                    subject.send(nil)
                }
            }
        listeners.append(listener)
        return subject.eraseToAnyPublisher()
    }
    
    func getUser(userId: String) async throws -> FirestoreUser? {
        let snapshot = try await usersCollection.document(userId).getDocument()
        return try snapshot.data(as: FirestoreUser.self)
    }
    
    func getUserWithEmail(email: String) async throws -> FirestoreUser? {
        let snapshot = try await usersCollection
            .whereField(FirestoreUserDataFields.email, isEqualTo: email)
            .getDocuments()
        
        return try snapshot.documents.first?.data(as: FirestoreUser.self)
    }
    
    func getUsers() async throws -> [FirestoreUser] {
        let snapshot = try await usersCollection
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: FirestoreUser.self) }
    }
    
    func createUser(firestoreUser: FirestoreUser) throws {
        let userData = try Firestore.Encoder().encode(firestoreUser)
        usersCollection.document(firestoreUser.userId).setData(userData)
    }
    
    func updateProfilePictureFileName(userId: String, fileName: String) {
        let userRef = usersCollection.document(userId)
        userRef.updateData([FirestoreUserDataFields.profilePictureFileName: fileName])
    }
    
    func deleteProfilePictureFileName(userId: String) {
        let userRef = usersCollection.document(userId)
        userRef.updateData([FirestoreUserDataFields.profilePictureFileName: FieldValue.delete()])
    }
    
    func stopListeningUsers() {
        listeners.removeAll()
    }
}
