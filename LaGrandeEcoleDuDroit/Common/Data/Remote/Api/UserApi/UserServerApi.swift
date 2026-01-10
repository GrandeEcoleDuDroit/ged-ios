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
        
        return try await RequestUtils.sendDataRequest(session: session, request: request)!
    }
    
    func getUser(userId: String) async throws -> OracleUser? {
        let url = RequestUtils.getUrl(base: base, endPoint: "/\(userId)")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.simpleGetRequest(url: url, authToken: authToken)
        
        return try await RequestUtils.sendDataRequest(session: session, request: request)
    }
    
    func createUser(serverUser: OracleUser) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/create")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: serverUser, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func updateProfilePicture(serverUser: OracleUser, imageData: Data, fileName: String) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/profile-picture/update")
        let session = RequestUtils.getDefaultSession()
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        let fileExtension = (fileName as NSString).pathExtension
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/\(fileExtension)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(UserField.Oracle.userId)\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(serverUser.userId)\r\n".data(using: .utf8)!)
        
        if let oldProfilePictureFileName = serverUser.userProfilePictureFileName {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(UserField.Oracle.userProfilePictureFileName)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(oldProfilePictureFileName)\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        if let authToken = await tokenProvider.getAuthToken() {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func deleteUser(serverUser: OracleUser) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/delete")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: serverUser, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func deleteProfilePicture(userId: String, profilePictureFileName: String) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/profile-picture/delete")
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
        let url = RequestUtils.getUrl(base: base, endPoint: "/report")
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
