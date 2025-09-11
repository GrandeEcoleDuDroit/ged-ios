import Foundation
import Combine

class UserRepositoryImpl: UserRepository {
    private let userLocalDataSource: UserLocalDataSource
    private let userRemoteDataSource: UserRemoteDataSource
    private let tag = String(describing: UserRepositoryImpl.self)
    private var userSubject = CurrentValueSubject<User?, Never>(nil)
    var user: AnyPublisher<User, Never> {
        userSubject
            .compactMap{ $0 }
            .eraseToAnyPublisher()
    }
    var currentUser: User? {
        userSubject.value
    }
    
    init(userLocalDataSource: UserLocalDataSource, userRemoteDataSource: UserRemoteDataSource) {
        self.userLocalDataSource = userLocalDataSource
        self.userRemoteDataSource = userRemoteDataSource
        initUser()
    }
    
    private func initUser() {
        userSubject.send(userLocalDataSource.getUser())
    }
    
    func createUser(user: User) async throws {
        try await mapFirebaseException(
            block: { try await userRemoteDataSource.createUser(user: user) },
            tag: tag,
            message: "Failed to create user"
        )
        try? userLocalDataSource.storeUser(user: user)
        userSubject.send(user)
    }
    
    func getUser(userId: String) async throws -> User? {
        try await userRemoteDataSource.getUser(userId: userId)
    }
    
    func getUserWithEmail(email: String) async throws -> User? {
        try await userRemoteDataSource.getUserWithEmail(email: email)
    }
    
    func getUserPublisher(userId: String) -> AnyPublisher<User, Error> {
        userRemoteDataSource.listenUser(userId: userId)
    }
    
    func getUsers() async -> [User] {
        await userRemoteDataSource.getUsers()
    }
    
    func storeUser(_ user: User) {
        try? userLocalDataSource.storeUser(user: user)
        userSubject.send(user)
    }
    
    func deleteCurrentUser() {
        userLocalDataSource.removeUser()
        userSubject.send(nil)
    }
    
    func updateProfilePictureFileName(userId: String, profilePictureFileName: String) async throws {
        try await mapFirebaseException(
            block: { try await userRemoteDataSource.updateProfilePictureFileName(userId: userId, fileName: profilePictureFileName) },
            tag: tag,
            message: "Failed to update profile picture file name"
        )

        try? userLocalDataSource.updateProfilePictureFileName(fileName: profilePictureFileName)
        userSubject.value = userSubject.value?.with(profilePictureUrl: UrlUtils.formatOracleBucketUrl(fileName: profilePictureFileName))
    }
    
    func deleteProfilePictureFileName(userId: String) async throws {
        try await mapFirebaseException(
            block: { try await userRemoteDataSource.deleteProfilePictureFileName(userId: userId) },
            tag: tag,
            message: "Failed to delete profile picture file name"
        )
        try? userLocalDataSource.updateProfilePictureFileName(fileName: nil)
        userSubject.value = userSubject.value?.with(profilePictureUrl: nil)
    }
}
