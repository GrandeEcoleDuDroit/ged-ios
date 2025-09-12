import Foundation

class UserOracleApiImpl: UserOracleApi {
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
