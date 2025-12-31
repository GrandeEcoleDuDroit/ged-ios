import Foundation

class FcmApiImpl: FcmApi {
    private let tokenProvider: TokenProvider
    private let base = "fcm"
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func addToken(userId: String, value: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "add-token")
        let dataToSend: [String: String] = ["userId": userId, "token": value]
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: dataToSend, authToken: authToken)
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func deleteToken(userId: String, value: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "delete-token")
        let dataToSend: [String: String] = ["userId": userId, "token": value]
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: dataToSend, authToken: authToken)
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func sendNotification(recipientId: String, fcmMessage: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "send-notification")
        let dataToSend: [String: String] = ["recipientId": recipientId,"fcmMessage": fcmMessage]
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: dataToSend, authToken: authToken)
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
}
