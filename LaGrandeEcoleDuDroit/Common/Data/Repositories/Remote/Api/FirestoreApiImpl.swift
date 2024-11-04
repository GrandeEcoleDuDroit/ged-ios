import FirebaseFirestore

class FirestoreApiImpl: FirestoreApi {
    private let usersCollection = Firestore.firestore().collection("users")
    
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
}
