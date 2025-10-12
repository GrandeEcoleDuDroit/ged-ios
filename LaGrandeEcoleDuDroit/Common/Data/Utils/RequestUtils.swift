import Foundation

class RequestUtils {
    static func getSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        return URLSession(configuration: config)
    }
    
    static func getUrl(base: String, endPoint: String) throws -> URL {
        if let url = URL.oracleUrl(path: "/\(base)/\(endPoint)") {
            return url
        } else {
            throw NetworkError.invalidURL("Invalid URL")
        }
    }
    
    static func formatGetRequest(
        url: URL,
        authToken: String? = nil
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let authToken {
            request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    static func formatPostRequest(
        dataToSend: Encodable,
        url: URL,
        authToken: String? = nil
    ) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(dataToSend)
        if let authToken {
            request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    static func formatPutRequest(
        dataToSend: Encodable,
        url: URL,
        authToken: String? = nil
    ) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(dataToSend)
        if let authToken {
            request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    static func formatDeleteRequest(url: URL, authToken: String? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        if let authToken {
            request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    static func sendRequest(session: URLSession, request: URLRequest) async throws -> (URLResponse, ServerResponse) {
        let (dataReceived, response) = try await session.data(for: request)
        let serverResponse = try JSONDecoder().decode(ServerResponse.self, from: dataReceived)
        return (response, serverResponse)
    }
}
