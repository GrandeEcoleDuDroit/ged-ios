import Foundation
import Combine

class UserRepositoryImpl: UserRepository {
    private let userLocalDataSource: UserLocalDataSource
    private let userRemoteDataSource: UserRemoteDataSource
    private let userSubject = CurrentValueSubject<User?, Never>(nil)
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
        let localUser = userLocalDataSource.getUser()
        userSubject.send(localUser)
    }
    
    func createUser(user: User) async throws {
        try await userRemoteDataSource.createUser(user: user)
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
        try await userRemoteDataSource.updateProfilePictureFileName(userId: userId, fileName: profilePictureFileName)

        try? userLocalDataSource.updateProfilePictureFileName(fileName: profilePictureFileName)
        var updatedUser = userSubject.value
        updatedUser?.profilePictureUrl = UrlUtils.formatProfilePictureUrl(fileName: profilePictureFileName)
        userSubject.send(updatedUser)
    }
    
    func deleteProfilePictureFileName(userId: String) async throws {
        try await userRemoteDataSource.deleteProfilePictureFileName(userId: userId)
        try? userLocalDataSource.updateProfilePictureFileName(fileName: nil)
        var updatedUser = userSubject.value
        updatedUser?.profilePictureUrl = nil
        userSubject.send(updatedUser)
    }
}
