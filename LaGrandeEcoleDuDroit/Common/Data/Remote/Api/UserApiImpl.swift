import Foundation
import Combine
import FirebaseFirestore

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
    
    func listenUser(userId: String) -> AnyPublisher<User?, any Error> {
        userFirestoreApi.listenUser(userId: userId)
            .map { $0?.toUser() }
            .eraseToAnyPublisher()
    }
    
    func getUser(userId: String) async throws -> User? {
        try await mapFirebaseException(
            block: { try await userFirestoreApi.getUser(userId: userId) },
            tag: tag,
            message: "Failed to get user \(userId) with firestore"
        )?.toUser()
    }
    
    func getUserWithEmail(email: String) async throws -> User? {
        try await mapFirebaseException(
            block: { try await userFirestoreApi.getUserWithEmail(email: email) },
            tag: tag,
            message: "Failed to get user \(email) with firestore"
        )?.toUser()
    }
    
    func getUsers() async throws -> [User] {
        try await mapFirebaseException(
            block: { try await userFirestoreApi.getUsers() },
            tag: tag,
            message: "Failed to get users with firestore"
        ).map { $0.toUser() }
    }
    
    func createUser(user: User) async throws {
        try await mapServerError(
            block: { try await userServerApi.createUser(user: user.toOracleUser()) },
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
        
        try await mapFirebaseException(
            block: { try userFirestoreApi.createUser(firestoreUser: user.toFirestoreUser()) },
            tag: tag,
            message: "Failed to create user \(user.fullName) with firestore"
        )
    }
    
    func updateProfilePictureFileName(userId: String, fileName: String) async throws {
        try await mapServerError(
            block: { try await userServerApi.updateProfilePictureFileName(userId: userId, fileName: fileName)},
            tag: tag,
            message: "Failed to update profile picture file name with server"
        )
        
        try await mapFirebaseException(
            block: { userFirestoreApi.updateProfilePictureFileName(userId: userId, fileName: fileName) },
            tag: tag,
            message: "Failed to update profile picture file name with firestore"
        )
    }
    
    func deleteUser(userId: String) async throws {
        try await mapServerError(
            block: { try await userServerApi.deleteUser(userId: userId) },
            tag: tag,
            message: "Failed to delete user with server"
        )
        
        try await mapFirebaseException(
            block: { try await userFirestoreApi.deleteUser(userId: userId) },
            tag: tag,
            message: "Failed to delete user with firestore"
        )
    }
    
    func deleteProfilePictureFileName(userId: String) async throws {
        try await mapServerError(
            block: { try await userServerApi.deleteProfilePictureFileName(userId: userId) },
            tag: tag,
            message: "Failed to delete profile picture file name with server"
        )
        
        try await mapFirebaseException(
            block: { userFirestoreApi.deleteProfilePictureFileName(userId: userId) },
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

class UserServerApi {
    private let tokenProvider: TokenProvider
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func createUser(user: OracleUser) async throws -> (URLResponse, ServerResponse) {
        let url = try getUrl(endPoint: "create")
        let session = RequestUtils.getUrlSession()
        let authIdToken = await tokenProvider.getAuthIdToken()
        let request = try RequestUtils.formatPostRequest(
            dataToSend: user,
            url: url,
            authToken: authIdToken
        )
        
        return try await sendRequest(session: session, request: request)
    }
    
    func updateProfilePictureFileName(userId: String, fileName: String) async throws -> (URLResponse, ServerResponse) {
        let url = try getUrl(endPoint: "profile-picture-file-name")
        let dataToSend: [String: String] = [
            OracleUserDataFields.userId: userId,
            OracleUserDataFields.userProfilePictureFileName: fileName
        ]
        
        let session = RequestUtils.getUrlSession()
        let authIdToken = await tokenProvider.getAuthIdToken()
        let request = try RequestUtils.formatPutRequest(
            dataToSend: dataToSend,
            url: url,
            authToken: authIdToken
        )
        
        return try await sendRequest(session: session, request: request)
    }
    
    func deleteUser(userId: String) async throws -> (URLResponse, ServerResponse) {
        let url = try getUrl(endPoint: "\(userId)")
        let session = RequestUtils.getUrlSession()
        let authIdToken = await tokenProvider.getAuthIdToken()
        let request = RequestUtils.formatDeleteRequest(
            url: url,
            authToken: authIdToken
        )
        
        return try await sendRequest(session: session, request: request)
    }
    
    func deleteProfilePictureFileName(userId: String) async throws -> (URLResponse, ServerResponse) {
       let url = try getUrl(endPoint: "profile-picture-file-name/\(userId)")
        let session = RequestUtils.getUrlSession()
        let authIdToken = await tokenProvider.getAuthIdToken()
        let request = RequestUtils.formatDeleteRequest(
            url: url,
            authToken: authIdToken
        )
        
        return try await sendRequest(session: session, request: request)
    }
    
    func reportUser(report: RemoteUserReport) async throws -> (URLResponse, ServerResponse) {
        let url = try getUrl(endPoint: "report")
        let session = RequestUtils.getUrlSession()
        let authIdToken = await tokenProvider.getAuthIdToken()
        let request = try RequestUtils.formatPostRequest(
            dataToSend: report,
            url: url,
            authToken: authIdToken
        )
        
        return try await sendRequest(session: session, request: request)
    }
    
    private func getUrl(endPoint: String) throws -> URL {
        if let url = URL.oracleUrl(path: "/users/\(endPoint)") {
            return url
        } else {
            throw NetworkError.invalidURL("Invalid URL")
        }
    }
    
    private func sendRequest(session: URLSession, request: URLRequest) async throws -> (URLResponse, ServerResponse) {
        let (dataReceived, response) = try await session.data(for: request)
        let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: dataReceived)
        return (response, serverResponse)
    }
}


class UserFirestoreApi {
    private let usersCollection: CollectionReference = Firestore.firestore().collection("users")
    
    func listenUser(userId: String) -> AnyPublisher<FirestoreUser?, Error> {
        let subject = CurrentValueSubject<FirestoreUser?, Error>(nil)
        
        usersCollection
            .document(userId)
            .addSnapshotListener { snapshot, error in
                if let error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                guard let snapshot = snapshot else { return }
                
                if let user = try? snapshot.data(as: FirestoreUser.self) {
                    subject.send(user)
                } else {
                    subject.send(nil)
                }
            }
        
        return subject.eraseToAnyPublisher()
    }
    
    func getUser(userId: String) async throws -> FirestoreUser? {
        let snapshot = try await usersCollection.document(userId).getDocument()
        return try snapshot.data(as: FirestoreUser.self)
    }
    
    func getUserWithEmail(email: String) async throws -> FirestoreUser? {
        let snapshot = try await usersCollection
            .whereField(FirestoreUserDataFields.email, isEqualTo: email)
            .getDocuments()
        
        return try snapshot.documents.first?.data(as: FirestoreUser.self)
    }
    
    func getUsers() async throws -> [FirestoreUser] {
        let snapshot = try await usersCollection
            .getDocuments()
        
        return try snapshot.documents.compactMap {
            try $0.data(as: FirestoreUser.self)
        }
    }
    
    func createUser(firestoreUser: FirestoreUser) throws {
        let userData = try Firestore.Encoder().encode(firestoreUser)
        usersCollection.document(firestoreUser.userId).setData(userData)
    }
    
    func updateProfilePictureFileName(userId: String, fileName: String) {
        let userRef = usersCollection.document(userId)
        userRef.updateData([FirestoreUserDataFields.profilePictureFileName: fileName])
    }
    
    func deleteUser(userId: String) async throws {
        let userRef = usersCollection.document(userId)
        try await userRef.delete()
    }
    
    func deleteProfilePictureFileName(userId: String) {
        let userRef = usersCollection.document(userId)
        userRef.updateData([FirestoreUserDataFields.profilePictureFileName: FieldValue.delete()])
    }
}
