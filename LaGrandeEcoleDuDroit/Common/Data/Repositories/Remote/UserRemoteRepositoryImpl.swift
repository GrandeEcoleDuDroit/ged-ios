class UserRemoteRepositoryImpl: UserRemoteRepository {
    private let firestoreApi: FirestoreApi
    
    init(firestoreApi: FirestoreApi) {
        self.firestoreApi = firestoreApi
    }
    
    func createUser(user: User) async throws {
        let firestoreUser = UserMapper.toFirestoreUser(user: user)
        async let firestoreResult: Void = firestoreApi.createUser(firestoreUser: firestoreUser)
        try await firestoreResult
    }
    
    func getUser(userId: String) async throws -> User? {
        let firestoreUser = try await firestoreApi.getUser(userId: userId)
        if firestoreUser != nil {
            return UserMapper.toDomain(firestoreUser: firestoreUser!)
        } else {
            return nil
        }
    }
}
