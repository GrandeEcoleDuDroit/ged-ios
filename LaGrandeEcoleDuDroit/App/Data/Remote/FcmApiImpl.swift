import Foundation

class FcmApiImpl: FcmApi {
    private let tokenProvider: TokenProvider
    private let base = "/fcm"
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func addToken(userId: String, value: String) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/add-token")
        let dataToSend: [String: String] = ["userId": userId, "token": value]
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: dataToSend, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func deleteToken(userId: String, value: String) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/delete-token")
        let dataToSend: [String: String] = ["userId": userId, "token": value]
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: dataToSend, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
    
    func sendNotification(userId: String, recipientId: String, fcmMessage: String) async throws {
        let url = RequestUtils.getUrl(base: base, endPoint: "/send-notification")
        let dataToSend: [String: String] = ["userId": userId, "recipientId": recipientId,"fcmMessage": fcmMessage]
        let session = RequestUtils.getDefaultSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: dataToSend, authToken: authToken)
        
        try await RequestUtils.sendRequest(session: session, request: request)
    }
}
