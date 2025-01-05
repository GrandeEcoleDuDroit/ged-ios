import Foundation

private let tag = String(describing: UserOracleApiImpl.self)

class UserOracleApiImpl: UserOracleApi {
    private func baseUrl(endPoint: String) -> URL? {
        URL.oracleUrl(endpoint: "/users/" + endPoint)
    }
    
    func createUser(user: OracleUser) async throws {
        guard let url = baseUrl(endPoint: "create") else {
            throw RequestError.invalidURL
        }
        
        let request = try RequestUtils.formatPostRequest(dataToSend: user, url: url)
        let session = RequestUtils.getUrlSession()
        
        let (dataReceived, response) = try await session.data(for: request)
        let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: dataReceived)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                e(tag, serverResponse.message)
            } else {
                e(tag, serverResponse.error ?? "Error to create user")
                throw RequestError.invalidResponse(serverResponse.error)
            }
        } else {
            e(tag, serverResponse.error ?? "Error to create user")
            throw RequestError.invalidResponse(serverResponse.error)
        }
    }
}
