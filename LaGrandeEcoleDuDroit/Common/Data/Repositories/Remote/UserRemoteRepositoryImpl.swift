class UserRemoteRepositoryImpl: UserRemoteRepository {
    private let userFirestoreApi: UserFirestoreApi
    private let userOracleApi: UserOracleApi
    
    init(userFirestoreApi: UserFirestoreApi, userOracleApi: UserOracleApi) {
        self.userFirestoreApi = userFirestoreApi
        self.userOracleApi = userOracleApi
    }
    
    func createUser(user: User) async throws {
        let firestoreUser = UserMapper.toFirestoreUser(user: user)
        let oracleUser = UserMapper.toOracleUser(user: user)
        
        async let firestoreResult: Void = userFirestoreApi.createUser(firestoreUser: firestoreUser)
        async let oracleResult: Void = userOracleApi.createUser(user: oracleUser)
        
        try await firestoreResult
        try await oracleResult
    }
    
    func getUser(userId: String) async throws -> User? {
        let firestoreUser = try await userFirestoreApi.getUser(userId: userId)
        if firestoreUser != nil {
            return UserMapper.toDomain(firestoreUser: firestoreUser!)
        } else {
            return nil
        }
    }
}
