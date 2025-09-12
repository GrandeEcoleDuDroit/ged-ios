import Foundation

class FcmApiImpl: FcmApi {
    private let tag = String(describing: FcmApiImpl.self)
    private let tokenProvider: TokenProvider
    
    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    private func baseUrl(endPoint: String) -> URL? {
        URL.oracleUrl(path: "/fcm/" + endPoint)
    }
    
    func addToken(userId: String, value: String) async throws -> (URLResponse, ServerResponse) {
        guard let url = baseUrl(endPoint: "add-token") else {
            throw NetworkError.invalidURL("Invalid URL")
        }
        
        let dataToSend: [String: String] = [
            "userId": userId,
            "token": value
        ]
        
        let session = RequestUtils.getUrlSession()
        let authIdToken = await tokenProvider.getAuthIdToken()
        let request = try RequestUtils.formatPostRequest(
            dataToSend: dataToSend,
            url: url,
            authToken: authIdToken
        )
        
        let (dataReceived, response) = try await session.data(for: request)
        let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: dataReceived)
        return (response, serverResponse)
    }
    
    func sendNotification(recipientId: String, fcmMessage: String) async throws -> (URLResponse, ServerResponse) {
        guard let url = baseUrl(endPoint: "send-notification") else {
            throw NetworkError.invalidURL("Invalid URL")
        }
        
        let dataToSend: [String: String] = [
            "recipientId": recipientId,
            "fcmMessage": fcmMessage
        ]
        let session = RequestUtils.getUrlSession()
        let authIdToken = await tokenProvider.getAuthIdToken()
        let request = try RequestUtils.formatPostRequest(
            dataToSend: dataToSend,
            url: url,
            authToken: authIdToken
        )
        
        let (dataReceived, response) = try await session.data(for: request)
        let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: dataReceived)
        return (response, serverResponse)
    }
}
