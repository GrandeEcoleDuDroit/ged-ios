import Foundation
import Combine

private let tag = String(describing: UserRepositoryImpl.self)

class UserRepositoryImpl: UserRepository {
    private let userLocalDataSource: UserLocalDataSource
    private let userRemoteDataSource: UserRemoteDataSource
    
    private var userSubject = CurrentValueSubject<User?, Never>(nil)
    var user: AnyPublisher<User, Never> {
        userSubject.compactMap{ $0 }.eraseToAnyPublisher()
    }
    var currentUser: User? {
        userSubject.value
    }
    
    init(userLocalDataSource: UserLocalDataSource, userRemoteDataSource: UserRemoteDataSource) {
        self.userLocalDataSource = userLocalDataSource
        self.userRemoteDataSource = userRemoteDataSource
        initUser()
    }
    
    func createUser(user: User) async throws {
        do {
            try await userRemoteDataSource.createUser(user: user)
            try? userLocalDataSource.storeUser(user: user)
            userSubject.send(user)
        } catch {
            e(tag, error.localizedDescription, error)
            throw error
        }
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
        userSubject.value = userSubject.value?.with(profilePictureFileName: profilePictureFileName)
    }
    
    func deleteProfilePictureFileName(userId: String) async throws {
        try await userRemoteDataSource.deleteProfilePictureFileName(userId: userId)
        try userLocalDataSource.updateProfilePictureFileName(fileName: nil)
        userSubject.value = userSubject.value?.with(profilePictureFileName: nil)
    }
    
    private func initUser() {
        userSubject.send(userLocalDataSource.getUser())
    }
}
