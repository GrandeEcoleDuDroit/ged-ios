import Foundation

class UserServerApi {
    private let tokenProvider: TokenProvider
    private let base = "/users"
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func getUsers() async throws -> [OracleUser] {
        let url = RequestUtils.getUrl(base: base)
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.simpleGetRequest(url: url, authToken: authToken)
        
        if let users: [OracleUser] = try await RequestUtils.sendDataRequest(session: session, request: request) {
            return users
        } else {
            throw NetworkError.unknown
        }
    }
    
    func getUser(userId: String) async throws -> OracleUser? {
        let url = RequestUtils.getUrl(base: base, endpoint: "/\(userId)")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.simpleGetRequest(url: url, authToken: authToken)
        
        return try await RequestUtils.sendDataRequest(session: session, request: request)
    }
    
    func createUser(serverUser: OracleUser) async throws {
        let url = RequestUtils.getUrl(base: base, endpoint: "/create")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: serverUser, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func updateProfilePicture(serverUser: OracleUser, fileData: FileData) async throws {
        let url = RequestUtils.getUrl(base: base, endpoint: "/profile-picture/update")
        let session = RequestUtils.getDefaultSession()
        var multipartRequest = MultipartRequest()

        multipartRequest.addImage(fileData: fileData)
        multipartRequest.addValue(name: UserField.Oracle.userId, value: serverUser.userId)
        if let oldProfilePictureFileName = serverUser.userProfilePictureFileName {
            multipartRequest.addValue(name: UserField.Oracle.userProfilePictureFileName, value: oldProfilePictureFileName)
        }

        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.post.rawValue
        request.httpBody = multipartRequest.body
        request.setValue(multipartRequest.headerValue, forHTTPHeaderField: "Content-Type")
        request.setValue(multipartRequest.body.count.description, forHTTPHeaderField: "Content-Length")
        if let authToken = await tokenProvider.getAuthToken() {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func deleteUser(serverUser: OracleUser) async throws {
        let url = RequestUtils.getUrl(base: base, endpoint: "/delete")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: serverUser, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func deleteProfilePicture(userId: String, profilePictureFileName: String) async throws {
        let url = RequestUtils.getUrl(base: base, endpoint: "/profile-picture/delete")
        let session = RequestUtils.getDefaultSession()
        let dataToSend = [
            UserField.Oracle.userId: userId,
            UserField.Oracle.userProfilePictureFileName: profilePictureFileName
        ]
        let authToken = await tokenProvider.getAuthToken()
        
        let request = try RequestUtils.simplePostRequest(
            url: url,
            dataToSend: dataToSend,
            authToken: authToken
        )
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func reportUser(report: RemoteUserReport) async throws {
        let url = RequestUtils.getUrl(base: base, endpoint: "/report")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(
            url: url,
            dataToSend: report,
            authToken: authToken
        )
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
}
