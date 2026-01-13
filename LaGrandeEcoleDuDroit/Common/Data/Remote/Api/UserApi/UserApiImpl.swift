import Foundation
import Combine

class UserApiImpl: UserApi {
    private let userFirestoreApi: UserFirestoreApi
    private let userServerApi: UserServerApi
    
    init(
        userFirestoreApi: UserFirestoreApi,
        userServerApi: UserServerApi
    ) {
        self.userFirestoreApi = userFirestoreApi
        self.userServerApi = userServerApi
    }
    
    func listenUser(userId: String) -> AnyPublisher<User?, Error> {
        userFirestoreApi.listenUser(userId: userId)
            .map { $0?.toUser() }
            .eraseToAnyPublisher()
    }
    
    func getUsers() async throws -> [User] {
        try await userServerApi.getUsers().map { $0.toUser() }
    }
    
    func getUser(userId: String) async throws -> User? {
        try await userServerApi.getUser(userId: userId)?.toUser()
    }
    
    func createUser(user: User) async throws {
        try await userServerApi.createUser(serverUser: user.toOracleUser())
    }
    
    func updateProfilePicture(user: User, imageData: Data, fileName: String) async throws {
        try await userServerApi.updateProfilePicture(
            serverUser: user.toOracleUser(),
            imageData: imageData,
            fileName: fileName
        )
    }
    
    func deleteUser(user: User) async throws {
        try await userServerApi.deleteUser(serverUser: user.toOracleUser())
    }
    
    func deleteProfilePicture(user: User) async throws {
        try await userServerApi.deleteProfilePicture(
            userId: user.id,
            profilePictureFileName: UserUtils.ProfilePicture.getFileName(url: user.profilePictureUrl)!
        )
    }
    
    func reportUser(report: UserReport) async throws {
        try await userServerApi.reportUser(report: report.toRemote())
    }
}
