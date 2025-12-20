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
    
    func getUsers() async -> [User] {
        (try? await userRemoteDataSource.getUsers()) ?? []
    }
    
    func getUserPublisher(userId: String, currentUser: User) -> AnyPublisher<User?, Error> {
        userRemoteDataSource.listenUser(userId: userId, currentUser: currentUser)
    }
    
    func getCurrentUser() -> User? {
        userLocalDataSource.getUser()
    }
    
    func getUser(userId: String, tester: Bool) async throws -> User? {
        try await userRemoteDataSource.getUser(userId: userId, tester: tester)
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
    
    func updateProfilePictureFileName(user: User, profilePictureFileName: String) async throws {
        try await userRemoteDataSource.updateProfilePictureFileName(user: user, fileName: profilePictureFileName)
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
    
    func deleteProfilePictureFileName(user: User) async throws {
        try await userRemoteDataSource.deleteProfilePictureFileName(user: user)
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
