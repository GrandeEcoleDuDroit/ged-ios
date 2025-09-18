import Combine
import Foundation

class UserRemoteDataSource {
    private let userApi: UserApi
    
    init(userApi: UserApi) {
        self.userApi = userApi
    }
    
    func listenUser(userId: String) -> AnyPublisher<User, Error> {
        userApi.listenUser(userId: userId)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    func getUser(userId: String) async throws -> User? {
        try await userApi.getUser(userId: userId)
    }
    
    func getUserWithEmail(email: String) async throws -> User? {
        try await userApi.getUserWithEmail(email: email)
    }
    
    func getUsers() async -> [User] {
        (try? await userApi.getUsers()) ?? []
    }
    
    func createUser(user: User) async throws {
        try await userApi.createUser(user: user)
    }
    
    func updateProfilePictureFileName(userId: String, fileName: String) async throws {
        try await userApi.updateProfilePictureFileName(userId: userId, fileName: fileName)
    }
    
    func deleteUser(user: User) async throws {
        try await userApi.deleteUser(userId: user.id)
    }
    
    func deleteProfilePictureFileName(userId: String) async throws {
        try await userApi.deleteProfilePictureFileName(userId: userId)
    }
    
    func reportUser(report: UserReport) async throws {
        try await userApi.reportUser(report: report)
    }
}
