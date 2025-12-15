import Foundation

class RequestUtils {
    private init() {}
    
    static func getDefaultSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        return URLSession(configuration: config)
    }
    
    static func formatOracleUrl(base: String, endPoint: String) throws -> URL {
        if let url = URL.oracleUrl(path: "/\(base)/\(endPoint)") {
            url
        } else {
            throw NetworkError.invalidURL("Invalid URL")
        }
    }
    
    static func simpleGetRequest(
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
    
    static func simplePostRequest(
        url: URL,
        authToken: String? = nil,
        dataToSend: Encodable,
    ) throws -> URLRequest {
        try simpleWriteRequest(method: "POST", url: url, authToken: authToken, data: dataToSend)
    }
    
    static func simplePutRequest(
        url: URL,
        authToken: String? = nil,
        dataToSend: Encodable
    ) throws -> URLRequest {
        try simpleWriteRequest(method: "PUT", url: url, authToken: authToken, data: dataToSend)
    }
    
    static func simplePatchRequest(
        url: URL,
        authToken: String? = nil,
        dataToSend: Encodable
    ) throws -> URLRequest {
       try simpleWriteRequest(method: "PATCH", url: url, authToken: authToken, data: dataToSend)
    }
    
    static func simpleDeleteRequest(url: URL, authToken: String? = nil) -> URLRequest {
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
    
    private static func simpleWriteRequest(
        method: String,
        url: URL,
        authToken: String?,
        data: Encodable
    ) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(data)
        if let authToken {
            request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
