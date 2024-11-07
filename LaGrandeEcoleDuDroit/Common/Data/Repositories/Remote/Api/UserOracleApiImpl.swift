import Foundation

class UserOracleApiImpl: UserOracleApi {
    private func baseUrl(endPoint: String) -> URL? {
        URL.oracleUrl(endpoint: "/users/" + endPoint)
    }
    
    func createUser(user: OracleUser) async throws {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        config.timeoutIntervalForResource = 20.0
        let session = URLSession(configuration: config)
        
        guard let url = baseUrl(endPoint: "create") else {
            throw RequestError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(user)
        
        let (data, response) = try await session.data(for: request)
        let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: data)
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
