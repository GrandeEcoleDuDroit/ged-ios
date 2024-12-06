import FirebaseFirestore

class UserFirestoreApiImpl: UserFirestoreApi {
    private let usersCollection: CollectionReference = Firestore.firestore().collection("users")
    
    func createUser(firestoreUser: FirestoreUser) async throws {
        let userData = try Firestore.Encoder().encode(firestoreUser)
        let userRef = usersCollection.document(firestoreUser.userId)
        try await userRef.setData(userData)
    }
    
    func getUser(userId: String) async throws -> FirestoreUser? {
        let snapshot = try await usersCollection.document(userId).getDocument()
        guard snapshot.exists else {
            return nil
        }
        
        return try snapshot.data(as: FirestoreUser.self)
    }
    
    func getUsers() async throws -> [FirestoreUser] {
        let snapshot = try await usersCollection.getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: FirestoreUser.self) }
    }
}
