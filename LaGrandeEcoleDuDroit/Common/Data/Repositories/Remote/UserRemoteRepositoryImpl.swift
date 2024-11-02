class UserRemoteRepositoryImpl: UserRemoteRepository {
    private let firestoreApi: FirestoreApi = FirestoreApiImpl()
    
    func createUser(user: User) async throws {
        let firestoreUser = UserMapper.toFirestoreUser(user: user)
        async let firestoreResult: Void = firestoreApi.createUser(firestoreUser: firestoreUser)
        try await firestoreResult
    }
}
