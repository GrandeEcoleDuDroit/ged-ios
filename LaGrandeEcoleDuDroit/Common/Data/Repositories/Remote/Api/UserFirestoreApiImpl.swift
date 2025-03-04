import FirebaseFirestore
import Combine

let userTableName = "users"

private let tag = String(describing: UserFirestoreApiImpl.self)

class UserFirestoreApiImpl: UserFirestoreApi {
    private let usersCollection: CollectionReference = Firestore.firestore().collection(userTableName)
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
    
    func getUserWithEmail(email: String) async throws -> FirestoreUser? {
        let snapshot = try await usersCollection
            .whereField(FirestoreUserDataFields.email, isEqualTo: email)
            .getDocuments()
        
        return try? snapshot.documents.first?.data(as: FirestoreUser.self)
    }
    
    func listenCurrentUser(userId: String) -> AnyPublisher<FirestoreUser?, Never> {
        let subject = CurrentValueSubject<FirestoreUser?, Never>(nil)
        
        let listener = usersCollection
            .document(userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    e(tag, "UserFirestoreApiImpl: Query error : \(error)")
                    subject.send(nil)
                    return
                }
                
                guard let snapshot = snapshot else {
                    e(tag, "UserFirestoreApiImpl: No snapshot for user: \(userId)")
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
        let snapshot = try await usersCollection
            .limit(to: 20)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: FirestoreUser.self) }
    }
    
    func getFilteredUsers(filter: String) async throws -> [FirestoreUser] {
        async let firstNameSnapshot = try await usersCollection
            .whereField(FirestoreUserDataFields.firstName, isGreaterThanOrEqualTo: filter)
            .whereField(FirestoreUserDataFields.firstName, isLessThanOrEqualTo: "\(filter)\u{f8ff}")
            .limit(to: 20)
            .getDocuments()
        
        async let lastNameSnapshot = try await usersCollection
            .whereField(FirestoreUserDataFields.lastName, isGreaterThanOrEqualTo: filter)
            .whereField(FirestoreUserDataFields.lastName, isLessThanOrEqualTo: "\(filter)\u{f8ff}")
            .limit(to: 20)
            .getDocuments()
        
        let firstNameUsers = try await firstNameSnapshot.documents.compactMap { try $0.data(as: FirestoreUser.self) }
        let lastNameUsers = try await lastNameSnapshot.documents.compactMap { try $0.data(as: FirestoreUser.self) }
        
        return Array(Set(firstNameUsers + lastNameUsers))
    }
    
    func stopListeningUsers() {
        listeners.removeAll()
    }
    
    func updateProfilePictureFileName(userId: String, fileName: String) async throws {
        let userRef = usersCollection.document(userId)
        try await userRef.updateData([FirestoreUserDataFields.profilePictureFileName: fileName])
    }
}
