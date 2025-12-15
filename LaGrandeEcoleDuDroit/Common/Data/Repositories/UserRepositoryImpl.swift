import Foundation
import Combine

class UserRepositoryImpl: UserRepository {
    private let userLocalDataSource: UserLocalDataSource
    private let userRemoteDataSource: UserRemoteDataSource
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
    
    func getCurrentUser() -> User? {
        userLocalDataSource.getUser()
    }
        
    func getUser(userId: String) async throws -> User? {
        try await userRemoteDataSource.getUser(userId: userId)
    }
    
    func getUserWithEmail(email: String) async throws -> User? {
        try await userRemoteDataSource.getUserWithEmail(email: email)
    }
    
    func getUserPublisher(userId: String) -> AnyPublisher<User?, Error> {
        userRemoteDataSource.listenUser(userId: userId)
    }
    
    func getUsers() async -> [User] {
        await userRemoteDataSource.getUsers()
    }
    
    func createUser(user: User) async throws {
        try await userRemoteDataSource.createUser(user: user)
        try? userLocalDataSource.storeUser(user: user)
        userSubject.send(user)
    }
    
    func storeUser(_ user: User) {
        try? userLocalDataSource.storeUser(user: user)
        userSubject.send(user)
    }
    
    func updateRemoteUser(user: User) async throws {
        try await userRemoteDataSource.updateUser(user: user)
    }
    
    func updateProfilePictureFileName(userId: String, profilePictureFileName: String) async throws {
        try await userRemoteDataSource.updateProfilePictureFileName(userId: userId, fileName: profilePictureFileName)
        try? userLocalDataSource.updateProfilePictureFileName(fileName: profilePictureFileName)
        let user = userSubject.value?.copy {
            $0.profilePictureUrl = UserUtils.ProfilePicture.url(fileName: profilePictureFileName)
        }
        userSubject.send(user)
    }
    
    func deleteLocalUser() {
        userLocalDataSource.removeUser()
        userSubject.send(nil)
    }
    
    func deleteProfilePictureFileName(userId: String) async throws {
        try await userRemoteDataSource.deleteProfilePictureFileName(userId: userId)
        try? userLocalDataSource.updateProfilePictureFileName(fileName: nil)
        let user = userSubject.value?.copy {
            $0.profilePictureUrl = nil
        }
        userSubject.send(user)
    }
    
    func reportUser(report: UserReport) async throws {
        try await userRemoteDataSource.reportUser(report: report)
    }
    
    private func initUser() {
        userSubject.send(userLocalDataSource.getUser())
    }
}
