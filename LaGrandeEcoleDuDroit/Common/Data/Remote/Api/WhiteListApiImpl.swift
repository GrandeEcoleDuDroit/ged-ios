import Foundation

class WhiteListApiImpl: WhiteListApi {
    private let base = "white-list"
    
    func isUserWhiteListed(email: String) async throws -> (URLResponse, Bool) {
        let url = try RequestUtils.getUrl(base: base, endPoint: "user")
        
        let dataToSend: [String: String] = [
            UserField.Server.userEmail: email
        ]
        
        let session = RequestUtils.getSession()
        let request = try RequestUtils.formatPostRequest(
            dataToSend: dataToSend,
            url: url
        )
        
        let (dataReceived, urlResponse) = try await session.data(for: request)
        let isWhiteListed = try? JSONDecoder().decode(Bool.self, from: dataReceived)
        return (urlResponse, isWhiteListed ?? false)
    }
}
