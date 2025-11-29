import Foundation

class MissionApiImpl: MissionApi {
    private let tokenProvider: TokenProvider
    private let base = "missions"

    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func getMissions() async throws -> (URLResponse, [InboundRemoteMission]) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "")
        
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.simpleGetRequest(
            url: url,
            authToken: authToken
        )
        
        let (data, urlResponse) = try await session.data(for: request)
        let missions = try JSONDecoder().decode([InboundRemoteMission].self, from: data)
        return (urlResponse, missions)
    }
    
    func createMission(remoteMission: OutboundRemoteMission, imageData: Data?) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "create")
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        if let imageFileName = remoteMission.missionImageFileName, let imageData {
            let fileExtension = (imageFileName as NSString).pathExtension
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; fileName=\"\(imageFileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/\(fileExtension)\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"mission\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
        body.append(try JSONEncoder().encode(remoteMission))
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        
        if let authToken = await tokenProvider.getAuthToken() {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        let session = RequestUtils.getDefaultSession()
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func deleteMission(missionId: String, imageFileName: String?) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "delete")
        let session = RequestUtils.getDefaultSession()
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var components = URLComponents()
        components.queryItems = []
        components.queryItems?.append(URLQueryItem(name: MissionField.Remote.missionId, value: missionId))
        if let imageFileName {
            components.queryItems?.append(URLQueryItem(name: MissionField.Remote.missionImageFileName, value: imageFileName))
        }
        request.httpBody = components.query?.data(using: .utf8)
        if let authToken = await tokenProvider.getAuthToken() {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
}
