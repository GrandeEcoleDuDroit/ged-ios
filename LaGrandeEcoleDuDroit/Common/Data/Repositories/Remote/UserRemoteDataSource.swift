import Combine
import Foundation

class UserRemoteDataSource {
    private let userFirestoreApi: UserFirestoreApi
    private let userOracleApi: UserOracleApi
    
    init(userFirestoreApi: UserFirestoreApi, userOracleApi: UserOracleApi) {
        self.userFirestoreApi = userFirestoreApi
        self.userOracleApi = userOracleApi
    }
    
    func createUser(user: User) async throws {
        try await userOracleApi.createUser(user: UserMapper.toOracleUser(user: user))
        try await userFirestoreApi.createUser(firestoreUser: UserMapper.toFirestoreUser(user: user))
    }
    
    func getUser(userId: String) async -> User? {
        let firestoreUser = await userFirestoreApi.getUser(userId: userId)
        return if let firestoreUser = firestoreUser {
            UserMapper.toDomain(firestoreUser: firestoreUser)
        } else {
            nil
        }
    }
    
    func getUserWithEmail(email: String) async throws -> User? {
        let firestoreUser = try await userFirestoreApi.getUserWithEmail(email: email)
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
    
    func updateProfilePictureFileName(userId: String, fileName: String) async throws {
        async let firestoreResult: Void = userFirestoreApi.updateProfilePictureFileName(userId: userId, fileName: fileName)
        async let oracleResult: Void = userOracleApi.updateProfilePictureFileName(userId: userId, fileName: fileName)
        
        try await firestoreResult
        try await oracleResult
    }
}
