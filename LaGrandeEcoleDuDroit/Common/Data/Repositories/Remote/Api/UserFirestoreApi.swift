import Combine

protocol UserFirestoreApi {
    func createUser(firestoreUser: FirestoreUser) async throws
    
    func getUser(userId: String) async -> FirestoreUser?
    
    func listenUser(userId: String) -> AnyPublisher<FirestoreUser?, Never>
    
    func getUsers() async throws -> [FirestoreUser]
    
    func stopListeningUsers()
}
