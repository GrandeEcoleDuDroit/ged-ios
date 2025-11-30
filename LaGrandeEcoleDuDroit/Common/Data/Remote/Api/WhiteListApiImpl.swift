import Foundation

class WhiteListApiImpl: WhiteListApi {
    private let base = "white-list"
    
    func isUserWhiteListed(email: String) async throws -> (URLResponse, Bool) {
        let url = try RequestUtils.formatOracleUrl(base: base, endPoint: "user")
        let session = RequestUtils.getDefaultSession()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: [UserField.Server.userEmail: email])
        
        let (dataReceived, urlResponse) = try await session.data(for: request)
        let isWhiteListed = try? JSONDecoder().decode(Bool.self, from: dataReceived)
        return (urlResponse, isWhiteListed ?? false)
    }
}
