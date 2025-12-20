import Combine
import FirebaseFirestore

class UserFirestoreApi {
    private let userCollection = Firestore.firestore().collection("users")
    
    func listenUser(userId: String, tester: Bool) -> AnyPublisher<FirestoreUser?, Error> {
        let subject = PassthroughSubject<FirestoreUser?, Error>()
        
        userCollection
            .whereField(UserField.Firestore.userId, isEqualTo: userId)
            .whereField(UserField.Firestore.tester, isEqualTo: tester)
            .addSnapshotListener { snapshot, error in
                if let error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                do {
                    let user = try snapshot?.documents.first?.data(as: FirestoreUser.self)
                    subject.send(user)
                } catch {
                    subject.send(completion: .failure(error))
                }
            }
        
        return subject.eraseToAnyPublisher()
    }
    
    func getUser(userId: String, tester: Bool) async throws -> FirestoreUser? {
        try await userCollection
            .whereField(UserField.Firestore.userId, isEqualTo: userId)
            .whereField(UserField.Firestore.tester, isEqualTo: tester)
            .getDocuments()
            .documents.first?.data(as: FirestoreUser.self)
    }
    
    func createUser(firestoreUser: FirestoreUser) throws {
        let data = try Firestore.Encoder().encode(firestoreUser)
        userCollection
            .document(firestoreUser.userId)
            .setData(data)
    }
    
    func updateProfilePictureFileName(userId: String, fileName: String) {
        let data = [UserField.Firestore.profilePictureFileName: fileName]
        userCollection
            .document(userId)
            .updateData(data)
    }
    
    func updateUser(firestoreUser: FirestoreUser) async throws {
        let data = try Firestore.Encoder().encode(firestoreUser)
        try await userCollection
            .document(firestoreUser.userId)
            .setData(data, merge: true)
    }
    
    func deleteProfilePictureFileName(userId: String) {
        let data = [UserField.Firestore.profilePictureFileName: FieldValue.delete()]
        userCollection
            .document(userId)
            .updateData(data)
    }
}
