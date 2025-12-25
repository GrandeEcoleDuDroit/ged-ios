import Foundation
import Combine

class UserApiImpl: UserApi {
    private let tag = String(describing: UserApiImpl.self)
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
        try await mapServerError(
            block: { try await userServerApi.getUsers() },
            tag: tag,
            message: "Failed to get users with server"
        ).map { $0.toUser() }
    }
    
    func getUser(userId: String) async throws -> User? {
        try await mapServerError(
            block: { try await userServerApi.getUser(userId: userId) },
            tag: tag,
            message: "Failed to get user \(userId)"
        )?.toUser()
    }
    
    func createUser(user: User) async throws {
        try await mapServerError(
            block: { try await userServerApi.createUser(serverUser: user.toServerUser()) },
            tag: tag,
            message: "Failed to create user \(user.fullName)",
            specificHandle: { urlResponse, serverResponse in
                if let httpResponse = urlResponse as? HTTPURLResponse {
                    if httpResponse.statusCode == 403 {
                        throw NetworkError.forbidden
                    }
                    throw parseOracleError(code: serverResponse.code, message: serverResponse.message)
                }
            }
        )
    }
    
    func updateProfilePicture(user: User, imageData: Data, fileName: String) async throws {
        try await mapServerError(
            block: {
                try await userServerApi.updateProfilePicture(serverUser: user.toServerUser(), imageData: imageData, fileName: fileName)
            },
            tag: tag,
            message: "Failed to update profile picture with server"
        )
    }
    
    func deleteUser(user: User) async throws {
        try await mapServerError(
            block: { try await userServerApi.deleteUser(serverUser: user.toServerUser()) },
            tag: tag,
            message: "Failed to delete user with server"
        )
    }
    
    func deleteProfilePicture(user: User) async throws {
        guard let fileName = UserUtils.ProfilePicture.getFileName(url: user.profilePictureUrl) else {
            throw CommonError.invalidArgument
        }
        try await mapServerError(
            block: { try await userServerApi.deleteProfilePicture(userId: user.id, profilePictureFileName: fileName) },
            tag: tag,
            message: "Failed to delete profile picture with server"
        )
    }
    
    func reportUser(report: UserReport) async throws {
        try await mapServerError(
            block: { try await userServerApi.reportUser(report: report.toRemote()) },
            tag: tag,
            message: "Failed to report user with server"
        )
    }
}
