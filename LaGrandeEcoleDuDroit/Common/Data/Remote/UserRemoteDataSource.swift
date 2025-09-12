import Combine
import Foundation

class UserRemoteDataSource {
    private let userFirestoreApi: UserFirestoreApi
    private let userOracleApi: UserOracleApi
    private let tag = String(describing: UserRemoteDataSource.self)
    
    init(userFirestoreApi: UserFirestoreApi, userOracleApi: UserOracleApi) {
        self.userFirestoreApi = userFirestoreApi
        self.userOracleApi = userOracleApi
    }
    
    func listenUser(userId: String) -> AnyPublisher<User, Error> {
        userFirestoreApi.listenUser(userId: userId)
            .compactMap { $0?.toUser() }
            .eraseToAnyPublisher()
    }
    
    func getUser(userId: String) async throws -> User? {
        try await mapFirebaseException {
            try await userFirestoreApi.getUser(userId: userId)?.toUser()
        }
    }
    
    func getUserWithEmail(email: String) async throws -> User? {
        try await mapFirebaseException {
            try await userFirestoreApi.getUserWithEmail(email: email)?.toUser()
        }
    }
    
    func getUsers() async -> [User] {
        (try? await userFirestoreApi.getUsers())?.map { $0.toUser() } ?? []
    }
    
    func createUser(user: User) async throws {
        try await createUserWithOracle(user: user)
        try await createUserWithFirestore(user: user)
    }
    
    func updateProfilePictureFileName(userId: String, fileName: String) async throws {
        try await mapServerError {
            try await userOracleApi.updateProfilePictureFileName(userId: userId, fileName: fileName)
        }
        
        try await mapFirebaseException {
            userFirestoreApi.updateProfilePictureFileName(userId: userId, fileName: fileName)
        }
    }
    
    func deleteUser(user: User) async throws {
        try await mapServerError {
            try await userOracleApi.deleteUser(userId: user.id)
        }
        
        try await mapFirebaseException {
            try await userFirestoreApi.deleteUser(userId: user.id)
        }
    }
    
    func deleteProfilePictureFileName(userId: String) async throws {
        try await mapServerError {
            try await userOracleApi.deleteProfilePictureFileName(userId: userId)
        }
        
        try await mapFirebaseException {
            userFirestoreApi.deleteProfilePictureFileName(userId: userId)
        }
    }
    
    private func createUserWithFirestore(user: User) async throws {
        try await mapFirebaseException {
            try userFirestoreApi.createUser(firestoreUser: user.toFirestoreUser())
        }
    }
    
    private func createUserWithOracle(user: User) async throws {
        try await mapServerError(
            block: { try await userOracleApi.createUser(user: user.toOracleUser()) },
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
}
