import Combine

class UserRemoteDataSource {
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
    
    func getUser(userId: String) async -> User? {
        let firestoreUser = await userFirestoreApi.getUser(userId: userId)
        return if let firestoreUser = firestoreUser {
            UserMapper.toDomain(firestoreUser: firestoreUser)
        } else {
            nil
        }
    }
    
    func listenUser(userId: String) -> AnyPublisher<User, Never> {
        userFirestoreApi.listenCurrentUser(userId: userId)
            .compactMap { firestoreUser in
                return if let firestoreUser = firestoreUser {
                    UserMapper.toDomain(firestoreUser: firestoreUser)
                } else {
                    nil
                }
            }.eraseToAnyPublisher()
    }
    
    func getUsers() async throws -> [User] {
        let firestoreUsers = try await userFirestoreApi.getUsers()
        return firestoreUsers.map { UserMapper.toDomain(firestoreUser: $0) }
    }
    
    func getFilteredUsers(filter: String) async -> [User] {
        do {
            let firestoreUsers = try await userFirestoreApi.getFilteredUsers(filter: filter)
            return firestoreUsers.map { UserMapper.toDomain(firestoreUser: $0) }
        } catch {
            return []
        }
    }
        
}
