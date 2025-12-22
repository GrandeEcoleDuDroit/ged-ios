import Combine
import Foundation

class UserRemoteDataSource {
    private let userApi: UserApi
    
    init(userApi: UserApi) {
        self.userApi = userApi
    }
    
    func listenUser(userId: String) -> AnyPublisher<User?, Error> {
        userApi.listenUser(userId: userId).eraseToAnyPublisher()
    }
    
    func getUsers() async throws -> [User] {
        try await userApi.getUsers()
    }
    
    func getUser(userId: String) async throws -> User? {
        try await userApi.getUser(userId: userId)
    }
    
    func createUser(user: User) async throws {
        try await userApi.createUser(user: user)
    }
    
    func updateProfilePictureFileName(user: User, fileName: String) async throws {
        try await userApi.updateProfilePictureFileName(user: user, fileName: fileName)
    }
    
    func updateUser(user: User) async throws {
        try await userApi.updateUser(user: user)
    }
    
    func deleteProfilePictureFileName(user: User) async throws {
        try await userApi.deleteProfilePictureFileName(user: user)
    }
    
    func reportUser(report: UserReport) async throws {
        try await userApi.reportUser(report: report)
    }
}
