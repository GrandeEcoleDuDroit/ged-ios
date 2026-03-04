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
    
    func updateProfilePicture(user: User, imageData: Data, fileName: String) async throws {
        try await userApi.updateProfilePicture(user: user, imageData: imageData, fileName: fileName)
    }
    
    func deleteUser(user: User) async throws {
        try await userApi.deleteUser(user: user)
    }
    
    func deleteProfilePicture(user: User) async throws {
        try await userApi.deleteProfilePicture(user: user)
    }
    
    func reportUser(report: UserReport) async throws {
        try await userApi.reportUser(report: report)
    }
}
