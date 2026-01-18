import Foundation

class MissionApiImpl: MissionApi {
    private let tokenProvider: TokenProvider
    private let base = "/missions"

    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func getMissions() async throws -> [InboundRemoteMission] {
        let url = RequestUtils.getUrl(base: base)
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.simpleGetRequest(url: url, authToken: authToken)
        
        if let missions: [InboundRemoteMission] = try await RequestUtils.sendDataRequest(session: session, request: request) {
            return missions
        } else {
            throw NetworkError.unknown
        }
    }
    
    func createMission(remoteMission: OutboundRemoteMission, imageData: Data?) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/create")
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
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func updateMission(remoteMission: OutboundRemoteMission, imageData: Data?) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/update")
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
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func deleteMission(remoteMission: OutboundRemoteMission) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/delete")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: remoteMission, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func addParticipant(missionId: String, oracleUser: OracleUser) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/add-participant")
        let session = RequestUtils.getDefaultSession()
        let data = [
            MissionField.Remote.missionId: missionId,
            UserField.Oracle.userId: oracleUser.userId,
            UserField.Oracle.userSchoolLevel: oracleUser.userSchoolLevel.description
        ]
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: data, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func removeParticipant(missionId: String, userId: String) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/remove-participant")
        let session = RequestUtils.getDefaultSession()
        let dataToSend = [MissionField.Remote.missionId: missionId, UserField.Oracle.userId: userId]
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: dataToSend, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func reportMission(report: RemoteMissionReport) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/report")
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: report, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
}
