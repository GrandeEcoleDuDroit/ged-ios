import Combine
import FirebaseFirestore

class UserFirestoreApi {
    private let userCollection = Firestore.firestore().collection("users")
    private var listeners: [String: ListenerRegistration] = [:]

    func listenUser(userId: String) -> AnyPublisher<FirestoreUser?, Error> {
        let subject = PassthroughSubject<FirestoreUser?, Error>()
        
        let listener = userCollection
            .document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error {
                    subject.send(completion: .failure(error))
                    self?.listeners.removeValue(forKey: userId)
                    return
                }
                
                if let user = try? snapshot?.data(as: FirestoreUser.self) {
                    subject.send(user)
                }
            }

        listeners[userId] = listener
        
        return subject.eraseToAnyPublisher()
    }
}
