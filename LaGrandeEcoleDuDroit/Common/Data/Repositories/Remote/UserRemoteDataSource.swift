import Combine
import Foundation

class UserRemoteDataSource {
    private let userFirestoreApi: UserFirestoreApi
    private let userOracleApi: UserOracleApi
    
    init(userFirestoreApi: UserFirestoreApi, userOracleApi: UserOracleApi) {
        self.userFirestoreApi = userFirestoreApi
        self.userOracleApi = userOracleApi
    }
    
    func listenUser(userId: String) -> AnyPublisher<User, Error> {
        userFirestoreApi.listenCurrentUser(userId: userId)
            .compactMap { firestoreUser in
                return if let firestoreUser = firestoreUser {
                    firestoreUser.toUser()
                } else {
                    nil
                }
            }.eraseToAnyPublisher()
    }
    
    func getUser(userId: String) async throws -> User? {
        if let firestoreUser = try await userFirestoreApi.getUser(userId: userId) {
            firestoreUser.toUser()
        } else {
            nil
        }
    }
    
    func getUserWithEmail(email: String) async throws -> User? {
        if let firestoreUser = try await userFirestoreApi.getUserWithEmail(email: email) {
            firestoreUser.toUser()
        } else {
            nil
        }
    }
    
    func getUsers() async -> [User] {
        if let firestoreUsers = try? await userFirestoreApi.getUsers() {
            firestoreUsers.map { $0.toUser() }
        } else {
            []
        }
    }
    
    func createUser(user: User) async throws {
        try await userOracleApi.createUser(user: user.toOracleUser())
        try userFirestoreApi.createUser(firestoreUser: user.toFirestoreUser())
    }
    
    func updateProfilePictureFileName(userId: String, fileName: String) async throws {
        try await userOracleApi.updateProfilePictureFileName(userId: userId, fileName: fileName)
        userFirestoreApi.updateProfilePictureFileName(userId: userId, fileName: fileName)
    }
    
    func deleteProfilePictureFileName(userId: String) async throws {
        try await userOracleApi.deleteProfilePictureFileName(userId: userId)
        userFirestoreApi.deleteProfilePictureFileName(userId: userId)
    }
}
