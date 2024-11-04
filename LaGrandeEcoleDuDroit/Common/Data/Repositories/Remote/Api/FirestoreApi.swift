protocol FirestoreApi {
    func createUser(firestoreUser: FirestoreUser) async throws
    
    func getUser(userId: String) async throws -> FirestoreUser?
}
