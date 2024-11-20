import Foundation

class UserOracleApiImpl: UserOracleApi {
    private func baseUrl(endPoint: String) -> URL? {
        URL.oracleUrl(endpoint: "/users/" + endPoint)
    }
    
    func createUser(user: OracleUser) async throws {
        guard let url = baseUrl(endPoint: "create") else {
            throw RequestError.invalidURL
        }
        
        let request = try DataUtils.formatPostRequest(dataToSend: user, url: url)
        let session = DataUtils.getUrlSession()
        
        let (dataReceived, response) = try await session.data(for: request)
        let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: dataReceived)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                print(serverResponse.message)
            } else {
                throw RequestError.invalidResponse(serverResponse.error)
            }
        } else {
            throw RequestError.invalidResponse(serverResponse.error)
        }
    }
}
