import Foundation

class UserServerApi {
    private let tokenProvider: TokenProvider
    private let base = "users"
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func getUsers() async throws -> (URLResponse, [ServerUser]) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.simpleGetRequest(url: url, authToken: authToken)
        
        let (data, urlResponse) = try await session.data(for: request)
        let users = try JSONDecoder().decode([ServerUser].self, from: data)
        return (urlResponse, users)
    }
    
    func createUser(serverUser: ServerUser) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "create")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, authToken: authToken, dataToSend: serverUser)
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func updateUser(serverUser: ServerUser) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "\(serverUser.userId)")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePutRequest(url: url, authToken: authToken, dataToSend: serverUser)
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func updateProfilePictureFileName(userId: String, fileName: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "profile-picture-file-name")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePatchRequest(
            url: url,
            authToken: authToken,
            dataToSend: [
                UserField.Server.userId: userId,
                UserField.Server.userProfilePictureFileName: fileName
            ]
        )
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func deleteProfilePictureFileName(userId: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "profile-picture-file-name/\(userId)")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.simpleDeleteRequest(url: url, authToken: authToken)
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func reportUser(report: RemoteUserReport) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "report")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, authToken: authToken, dataToSend: report)
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
}
