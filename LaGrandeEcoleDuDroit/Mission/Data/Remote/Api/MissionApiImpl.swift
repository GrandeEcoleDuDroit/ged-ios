import Foundation

class MissionApiImpl: MissionApi {
    private let tokenProvider: TokenProvider
    private let base = "missions"

    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func getMissions() async throws -> (URLResponse, [InboundRemoteMission]) {
        let url = try RequestUtils.formatOracleUrl(base: base)
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.simpleGetRequest(url: url, authToken: authToken)
        
        let (data, urlResponse) = try await session.data(for: request)
        let missions = try JSONDecoder().decode([InboundRemoteMission].self, from: data)
        return (urlResponse, missions)
    }
    
    func createMission(remoteMission: OutboundRemoteMission, imageData: Data?) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "create")
        let session = RequestUtils.getDefaultSession()
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        if let imageData, let imageFileName = remoteMission.missionImageFileName {
            let fileExtension = (imageFileName as NSString).pathExtension
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(imageFileName)\"\r\n".data(using: .utf8)!)
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
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func updateMission(remoteMission: OutboundRemoteMission, imageData: Data?) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "update")
        let session = RequestUtils.getDefaultSession()
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        if let imageData, let imageFileName = remoteMission.missionImageFileName {
            let fileExtension = (imageFileName as NSString).pathExtension
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(imageFileName)\"\r\n".data(using: .utf8)!)
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
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func deleteMission(remoteMission: OutboundRemoteMission) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "delete")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: remoteMission, authToken: authToken)
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func addParticipant(remoteAddMissionParticipant: RemoteAddMissionParticipant) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "add-participant")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: remoteAddMissionParticipant, authToken: authToken)
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func removeParticipant(missionId: String, userId: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "remove-participant")
        let session = RequestUtils.getDefaultSession()
        let dataToSend = [MissionField.Remote.missionId: missionId, UserField.Server.userId: userId]
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: dataToSend, authToken: authToken)
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func reportMission(report: RemoteMissionReport) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "report")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: report, authToken: authToken)
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
}
