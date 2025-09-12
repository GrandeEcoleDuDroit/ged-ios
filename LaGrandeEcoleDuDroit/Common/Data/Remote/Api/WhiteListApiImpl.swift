import Foundation

class WhiteListApiImpl: WhiteListApi {    
    private func baseUrl(endPoint: String) -> URL? {
        URL.oracleUrl(path: "/white-list" + endPoint)
    }
    
    func isUserWhiteListed(email: String) async throws -> (URLResponse, Bool) {
        guard let url = baseUrl(endPoint: "/user") else {
            throw NetworkError.invalidURL("Invalid URL")
        }
        
        let dataToSend: [String: String] = [
            OracleUserDataFields.userEmail: email
        ]
        
        let session = RequestUtils.getUrlSession()
        let request = try RequestUtils.formatPostRequest(
            dataToSend: dataToSend,
            url: url
        )
        
        let (dataReceived, urlResponse) = try await session.data(for: request)
        
        let isWhiteListed = try? JSONDecoder().decode(Bool.self, from: dataReceived)
        return (urlResponse, isWhiteListed ?? false)
    }
}
