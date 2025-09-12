import Combine

protocol UserFirestoreApi {
    func listenUser(userId: String) -> AnyPublisher<FirestoreUser?, Error>

    func getUser(userId: String) async throws -> FirestoreUser?
    
    func getUserWithEmail(email: String) async throws -> FirestoreUser?
        
    func getUsers() async throws -> [FirestoreUser]
    
    func createUser(firestoreUser: FirestoreUser) throws
        
    func updateProfilePictureFileName(userId: String, fileName: String)
    
    func deleteUser(userId: String) async throws
    
    func deleteProfilePictureFileName(userId: String)
    
    func stopListeningUsers()
}
