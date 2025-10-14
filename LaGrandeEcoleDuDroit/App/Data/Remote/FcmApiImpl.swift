import Foundation

class FcmApiImpl: FcmApi {
    private let tokenProvider: TokenProvider
    private let base = "fcm"
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func addToken(userId: String, value: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.getUrl(base: base, endPoint: "add-token")
        
        let dataToSend: [String: String] = [
            "userId": userId,
            "token": value
        ]
        
        let session = RequestUtils.getSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.formatPostRequest(
            dataToSend: dataToSend,
            url: url,
            authToken: authToken
        )
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func sendNotification(recipientId: String, fcmMessage: String) async throws -> (URLResponse, ServerResponse) {
        let url = try RequestUtils.getUrl(base: base, endPoint: "send-notification")
        
        let dataToSend: [String: String] = [
            "recipientId": recipientId,
            "fcmMessage": fcmMessage
        ]
        let session = RequestUtils.getSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.formatPostRequest(
            dataToSend: dataToSend,
            url: url,
            authToken: authToken
        )
        
        return try await RequestUtils.sendRequest(session: session, request: request)
    }
}
