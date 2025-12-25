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
    
    func getUserPublisher(userId: String) -> AnyPublisher<User?, Error> {
        userRemoteDataSource.listenUser(userId: userId)
    }
    
    func getCurrentUser() -> User? {
        userLocalDataSource.getUser()
    }
    
    func getUser(userId: String) async throws -> User? {
        try await userRemoteDataSource.getUser(userId: userId)
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
    
    func updateProfilePicture(user: User, imageData: Data, fileName: String) async throws {
        try await userRemoteDataSource.updateProfilePicture(user: user, imageData: imageData, fileName: fileName)
        try? userLocalDataSource.updateProfilePictureFileName(fileName: fileName)
    }
    
    func deleteUser(user: User) async throws {
        try await userRemoteDataSource.deleteUser(user: user)
        userLocalDataSource.deleteUser()
        userSubject.send(nil)
    }
    
    func deleteLocalUser() {
        userLocalDataSource.deleteUser()
    }
    
    func deleteProfilePicture(user: User) async throws {
        try await userRemoteDataSource.deleteProfilePicture(user: user)
        try? userLocalDataSource.updateProfilePictureFileName(fileName: nil)
    }
    
    func reportUser(report: UserReport) async throws {
        try await userRemoteDataSource.reportUser(report: report)
    }
    
    private func initUser() {
        userSubject.send(userLocalDataSource.getUser())
    }
}
