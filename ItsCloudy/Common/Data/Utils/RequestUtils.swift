import Foundation

struct RequestUtils {
    private init() {}
    
    static func getUrl(base: String, endpoint: String = "") -> URL {
        URL(string: base + endpoint, relativeTo: URL(string: GedConfiguration.serverUrl))!
    }
    
    static func getDefaultSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        return URLSession(configuration: config)
    }
    
    static func simpleGetRequest(
        url: URL,
        authToken: String? = nil
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.get.rawValue
        if let authToken {
            request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    static func simplePostRequest(
        url: URL,
        dataToSend: Encodable,
        authToken: String? = nil
    ) throws -> URLRequest {
        try simpleWriteRequest(method: HttpMethod.post.rawValue, url: url, authToken: authToken, data: dataToSend)
    }
    
    static func simplePutRequest(
        url: URL,
        dataToSend: Encodable,
        authToken: String? = nil
    ) throws -> URLRequest {
        try simpleWriteRequest(method: HttpMethod.put.rawValue, url: url, authToken: authToken, data: dataToSend)
    }
    
    static func simplePatchRequest(
        url: URL,
        dataToSend: Encodable,
        authToken: String? = nil
    ) throws -> URLRequest {
        try simpleWriteRequest(method: HttpMethod.patch.rawValue, url: url, authToken: authToken, data: dataToSend)
    }
    
    static func simpleDeleteRequest(url: URL, authToken: String? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.delete.rawValue
        if let authToken {
            request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    static func sendRequest(session: URLSession, request: URLRequest) async throws {
        do {
            let (dataReceived, urlResponse) = try await session.data(for: request)
            
            if let httpCode = (urlResponse as? HTTPURLResponse)?.statusCode, httpCode >= 400 {
                if let serverResponse = try? JSONDecoder().decode(ServerResponse.self, from: dataReceived) {
                    throw ServerError(httpCode: httpCode, message: serverResponse.message, errorCode: serverResponse.code)
                } else {
                    throw NetworkError.unknown
                }
            }
        } catch let error as ServerError {
            throw mapServerError(error)
        }
    }
    
    static func sendDataRequest<T: Decodable>(session: URLSession, request: URLRequest) async throws  -> T? {
        do {
            let (dataReceived, urlResponse) = try await session.data(for: request)
            
            if let httpCode = (urlResponse as? HTTPURLResponse)?.statusCode, httpCode >= 400 {
                if let serverResponse = try? JSONDecoder().decode(ServerResponse.self, from: dataReceived) {
                    throw ServerError(httpCode: httpCode, message: serverResponse.message, errorCode: serverResponse.code)
                } else {
                    throw NetworkError.unknown
                }
            } else {
                let receivedData = try? JSONDecoder().decode(T.self, from: dataReceived)
                return receivedData
            }
        } catch let error as ServerError {
            throw mapServerError(error)
        }
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
