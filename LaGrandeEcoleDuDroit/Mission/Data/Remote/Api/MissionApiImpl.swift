import Foundation

class MissionApiImpl: MissionApi {
    private let tokenProvider: TokenProvider
    private let base = "missions"

    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func getMissions() async throws -> (URLResponse, [InboundRemoteMission]) {
        let url = try RequestUtils.getUrl(base: base, endPoint: "")
        
        let session = RequestUtils.getSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.formatGetRequest(
            url: url,
            authToken: authToken
        )
        
        let (data, urlResponse) = try await session.data(for: request)
        let missions = try JSONDecoder().decode([InboundRemoteMission].self, from: data)
        return (urlResponse, missions)
    }
    
    func createMission(
        remoteMission: OutboundRemoteMission,
        imageFileName: String?,
        imageData: Data?
    ) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.getUrl(base: base, endPoint: "")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        body.append("Content-Type: multipart/form-data; boundary=\(boundary)\r\n\r\n".data(using: .utf8)!)
        
        if let imageFileName, let imageData {
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
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        request.httpBody = body
        if let authToken = await tokenProvider.getAuthToken() {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        let session = RequestUtils.getSession()
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
}
