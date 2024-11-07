import FirebaseFirestore

class UserFirestoreApiImpl: UserFirestoreApi {
    private let usersCollection: CollectionReference
    
    init() {
        let db = Firestore.firestore()
        #if DEBUG
        let settings = db.settings
        settings.host = "127.0.0.1:8080"
        settings.cacheSettings = MemoryCacheSettings()
        settings.isSSLEnabled = false
        db.settings = settings
        #endif
        usersCollection = db.collection("users")
    }
    
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
