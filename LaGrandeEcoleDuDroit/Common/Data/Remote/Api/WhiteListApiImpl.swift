import Foundation

class WhiteListApiImpl: WhiteListApi {
    private let base = "/white-list"
    
    func isUserWhiteListed(email: String) async throws -> Bool {
        let url = RequestUtils.getUrl(base: base, endPoint: "/user")
        let session = RequestUtils.getDefaultSession()
        let request = try RequestUtils.simplePostRequest(url: url, dataToSend: [UserField.Oracle.userEmail: email])
        
        return try await RequestUtils.sendDataRequest(session: session, request: request)!
    }
}
