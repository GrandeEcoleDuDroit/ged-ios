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
    
    func listenUser(userId: String) -> AnyPublisher<User?, Error> {
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
    
    func updateUser(user: User) async throws {
        try await mapServerError(
            block: { try await userServerApi.updateUser(serverUser: user.toServerUser()) },
            tag: tag,
            message: "Failed to update user with server"
        )
        
        try await mapFirebaseException(
            block: { try await userFirestoreApi.updateUser(firestoreUser: user.toFirestoreUser()) },
            tag: tag,
            message: "Failed to update user with firestore"
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
    private let base = "users"
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func createUser(serverUser: ServerUser) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.getUrl(base: base, endPoint: "create")
        let session = RequestUtils.getSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.formatPostRequest(
            dataToSend: serverUser,
            url: url,
            authToken: authToken
        )
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func updateUser(serverUser: ServerUser) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.getUrl(base: base, endPoint: "\(serverUser.userId)")
        let session = RequestUtils.getSession()
        let authToken = await tokenProvider.getAuthToken()
        
        let request = try RequestUtils.formatPutRequest(
            dataToSend: serverUser,
            url: url,
            authToken: authToken
        )
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func updateProfilePictureFileName(userId: String, fileName: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.getUrl(base: base, endPoint: "profile-picture-file-name")
        let dataToSend: [String: String] = [
            OracleUserDataFields.userId: userId,
            OracleUserDataFields.userProfilePictureFileName: fileName
        ]
        let session = RequestUtils.getSession()
        let authToken = await tokenProvider.getAuthToken()
        
        let request = try RequestUtils.formatPatchRequest(
            dataToSend: dataToSend,
            url: url,
            authToken: authToken
        )
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func deleteProfilePictureFileName(userId: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.getUrl(base: base, endPoint: "profile-picture-file-name/\(userId)")
        let session = RequestUtils.getSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.formatDeleteRequest(
            url: url,
            authToken: authToken
        )
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func reportUser(report: RemoteUserReport) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.getUrl(base: base, endPoint: "report")
        let session = RequestUtils.getSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.formatPostRequest(
            dataToSend: report,
            url: url,
            authToken: authToken
        )
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
}


class UserFirestoreApi {
    private let usersCollection: CollectionReference = Firestore.firestore().collection("users")
    
    func listenUser(userId: String) -> AnyPublisher<FirestoreUser?, Error> {
        let subject = PassthroughSubject<FirestoreUser?, Error>()
        
        usersCollection
            .document(userId)
            .addSnapshotListener { snapshot, error in
                if let error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                do {
                    let user = try snapshot?.data(as: FirestoreUser.self)
                    subject.send(user)
                } catch {
                    subject.send(completion: .failure(error))
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
    
    func updateUser(firestoreUser: FirestoreUser) async throws {
        let userRef = usersCollection.document(firestoreUser.userId)
        let userData = try Firestore.Encoder().encode(firestoreUser)
        try await userRef.setData(userData, merge: true)
    }
    
    func deleteProfilePictureFileName(userId: String) {
        let userRef = usersCollection.document(userId)
        userRef.updateData([FirestoreUserDataFields.profilePictureFileName: FieldValue.delete()])
    }
}
