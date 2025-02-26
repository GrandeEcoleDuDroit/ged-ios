import Combine

protocol UserFirestoreApi {
    func createUser(firestoreUser: FirestoreUser) async throws
    
    func getUser(userId: String) async -> FirestoreUser?
    
    func getUserWithEmail(email: String) async -> FirestoreUser?
    
    func listenCurrentUser(userId: String) -> AnyPublisher<FirestoreUser?, Never>
    
    func getUsers() async throws -> [FirestoreUser]
    
    func getFilteredUsers(filter: String) async throws -> [FirestoreUser]
    
    func stopListeningUsers()
}
