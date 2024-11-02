class UserRemoteRepositoryImpl: UserRemoteRepository {
    private let oracleApi: OracleApi = OracleApiImpl()
    private let firestoreApi: FirestoreApi = FirestoreApiImpl()
    
    func createUser(user: User) async throws {
        let firestoreUser = UserMapper.toFirestoreUser(user: user)
        async let firestoreResult: Void = firestoreApi.createUser(firestoreUser: firestoreUser)
//        let oracleUser = UserMapper.toOracleUser(user: user)
//        async let oracleResult: Void = oracleApi.createUser(oracleUser: oracleUser)

        try await (firestoreResult/*, oracleResult*/)
    }
}
