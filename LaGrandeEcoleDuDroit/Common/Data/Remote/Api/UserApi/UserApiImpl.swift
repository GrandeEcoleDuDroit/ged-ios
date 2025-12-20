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
    
    func listenUser(userId: String, currentUser: User) -> AnyPublisher<User?, Error> {
        userFirestoreApi.listenUser(userId: userId, tester: currentUser.tester)
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
    
    func getUser(userId: String, tester: Bool) async throws -> User? {
        try await mapFirebaseError(
            block: { try await userFirestoreApi.getUser(userId: userId, tester: tester) },
            tag: tag,
            message: "Failed to get user \(userId) with firestore"
        )?.toUser()
    }
    
    func createUser(user: User) async throws {
        try await mapServerError(
            block: { try await userServerApi.createUser(serverUser: user.toServerUser()) },
            tag: tag,
            message: "Failed to create user \(user.fullName) with server",
            specificHandle: { urlResponse, serverResponse in
                if let httpResponse = urlResponse as? HTTPURLResponse {
                    if httpResponse.statusCode == 403 {
                        throw NetworkError.forbidden
                    }
                    throw parseOracleError(code: serverResponse.code, message: serverResponse.message)
                }
            }
        )
        
        try await mapFirebaseError(
            block: { try userFirestoreApi.createUser(firestoreUser: user.toFirestoreUser()) },
            tag: tag,
            message: "Failed to create user \(user.fullName) with firestore"
        )
    }
    
    func updateProfilePictureFileName(user: User, fileName: String) async throws {
        try await mapServerError(
            block: {
                try await userServerApi.updateProfilePictureFileName(
                    userId: user.id,
                    fileName: fileName)
            },
            tag: tag,
            message: "Failed to update profile picture file name with server"
        )
        
        try await mapFirebaseError(
            block: {
                userFirestoreApi.updateProfilePictureFileName(userId: user.id,fileName: fileName)
            },
            tag: tag,
            message: "Failed to update profile picture file name with firestore"
        )
    }
    
    func updateUser(user: User) async throws {
        try await mapServerError(
            block: { try await userServerApi.updateUser(serverUser: user.toServerUser()) },
            tag: tag,
            message: "Failed to update user with server"
        )
        
        try await mapFirebaseError(
            block: { try await userFirestoreApi.updateUser(firestoreUser: user.toFirestoreUser()) },
            tag: tag,
            message: "Failed to update user with firestore"
        )
    }
    
    func deleteProfilePictureFileName(user: User) async throws {
        try await mapServerError(
            block: { try await userServerApi.deleteProfilePictureFileName(userId: user.id) },
            tag: tag,
            message: "Failed to delete profile picture file name with server"
        )
        
        try await mapFirebaseError(
            block: { userFirestoreApi.deleteProfilePictureFileName(userId: user.id) },
            tag: tag,
            message: "Failed to delete profile picture file name with firestore"
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
